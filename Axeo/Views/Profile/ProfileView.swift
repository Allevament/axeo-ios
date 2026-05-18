import SwiftUI
import SwiftData
import StoreKit
import PhotosUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL
    @Query(sort: \Session.endedAt, order: .reverse) private var sessions: [Session]

    @State private var editingName = false
    @State private var nameText = ""
    @State private var showPaywall = false
    @State private var showDisclaimer = false
    @State private var showResetConfirm = false
    @State private var showReferSheet = false
    @State private var showLanguagePicker = false
    @State private var showThemePicker = false
    @State private var showNotificationPicker = false
    @State private var showGoalPicker = false
    @State private var showDiagnosisPicker = false
    @State private var showPrivacyPolicy = false

    // Photo picker
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false

    // Notifications
    private let notificationManager = NotificationManager.shared

    private var user: User? { appState.currentUser }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatarSection
                    if !appState.isPremium {
                        UpgradePromptView(context: .profile) {
                            showPaywall = true
                        }
                    }
                    statsOverview
                    settingsSection
                    aboutSection
                    dangerZone
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background { AmbientBackground() }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showDisclaimer) {
                DisclaimerSheet()
            }
            .sheet(isPresented: $showLanguagePicker) {
                languagePickerSheet
            }
            .sheet(isPresented: $showThemePicker) {
                themePickerSheet
            }
            .sheet(isPresented: $showNotificationPicker) {
                notificationPickerSheet
            }
            .sheet(isPresented: $showGoalPicker) {
                goalPickerSheet
            }
            .sheet(isPresented: $showDiagnosisPicker) {
                diagnosisPickerSheet
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .confirmationDialog(
                NSLocalizedString("Reset All Data?", comment: ""),
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("Delete Everything", comment: ""), role: .destructive) {
                    resetAllData()
                }
                Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
            } message: {
                Text("This will permanently delete all sessions, test results, and progress. This cannot be undone.")
            }
        }
    }

    // MARK: – Avatar

    private var avatarSection: some View {
        VStack(spacing: 12) {
            // Profile photo / initials avatar
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    if let data = user?.profilePhotoData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(avatarGradient)
                            .frame(width: 72, height: 72)

                        Text(initials)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    // Camera badge
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 26, height: 26)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.aveoAccent)
                        }
                        .overlay {
                            Circle().strokeBorder(Color.aveoBg, lineWidth: 2)
                        }
                        .offset(x: 28, y: 28)
                }
            }
            .buttonStyle(.plain)
            .onChange(of: selectedPhoto) { _, newItem in
                guard let newItem else { return }
                loadPhoto(from: newItem)
            }
            .accessibilityLabel(NSLocalizedString("Change profile photo", comment: ""))
            .overlay {
                if isLoadingPhoto {
                    ProgressView()
                        .tint(Color.aveoAccent)
                }
            }

            if editingName {
                HStack(spacing: 8) {
                    TextField("Name", text: $nameText)
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                .overlay { RoundedRectangle(cornerRadius: 10).fill(Color.aveoGlass) }
                        }
                        .frame(width: 200)

                    Button {
                        HapticManager.success()
                        saveName()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoTeal)
                    }
                }
            } else {
                Button {
                    HapticManager.light()
                    nameText = user?.displayName ?? NSLocalizedString("Guest", comment: "")
                    editingName = true
                } label: {
                    HStack(spacing: 4) {
                        Text(user?.displayName ?? NSLocalizedString("Guest", comment: ""))
                            .font(.aveoTitle)
                            .foregroundStyle(Color.aveoText)
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }

            // Goal & diagnosis badges
            HStack(spacing: 8) {
                if let goal = user?.goal {
                    profileBadge(goal.displayName, icon: goal.icon, color: .aveoTeal)
                }
                if let diag = user?.diagnosis, diag != .none {
                    profileBadge(diag.displayName, color: .aveoAccent)
                }
                if appState.isPremium {
                    profileBadge(NSLocalizedString("Premium", comment: ""), icon: "star.fill", color: .aveoGold)
                }
            }
        }
        .padding(.top, 8)
    }

    private func profileBadge(_ text: String, icon: String? = nil, color: Color) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .overlay { Capsule().fill(color.opacity(0.08)) }
        }
        .overlay {
            Capsule().strokeBorder(color.opacity(0.15), lineWidth: 0.5)
        }
    }

    private var initials: String {
        let name = user?.displayName ?? "G"
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var avatarGradient: LinearGradient {
        let name = user?.displayName ?? "Guest"
        let hue = Double(abs(name.hashValue) % 360) / 360.0
        let c1 = Color(hue: hue, saturation: 0.65, brightness: 0.85)
        let c2 = Color(hue: (hue + 0.08).truncatingRemainder(dividingBy: 1.0), saturation: 0.55, brightness: 0.7)
        return LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: – Stats Overview

    private var statsOverview: some View {
        let completed = sessions.filter(\.completed)
        let total = completed.count
        let minutes = completed.reduce(0) { $0 + $1.totalDurationSec } / 60

        return HStack(spacing: 0) {
            miniStat(value: "\(total)", label: NSLocalizedString("Workouts", comment: ""))
            miniStat(value: "\(minutes)", label: NSLocalizedString("Minutes", comment: ""))
            miniStat(value: memberSince, label: NSLocalizedString("Member Since", comment: ""))
        }
        .glassCard(cornerRadius: 16, padding: 0)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.aveoText)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var memberSince: String {
        guard let date = user?.createdAt else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: – Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SETTINGS")
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)

            settingsRow(icon: "eye.fill", label: NSLocalizedString("Change Goal", comment: ""), detail: user?.goal.displayName ?? "") {
                showGoalPicker = true
            }

            settingsRow(icon: "eye.trianglebadge.exclamationmark", label: NSLocalizedString("Eye Condition", comment: ""), detail: user?.diagnosis?.displayName ?? NSLocalizedString("None", comment: "")) {
                showDiagnosisPicker = true
            }

            settingsRow(icon: "globe", label: NSLocalizedString("Language", comment: ""), detail: currentLanguageLabel, color: .aveoTeal) {
                showLanguagePicker = true
            }

            settingsRow(icon: appState.theme.icon, label: NSLocalizedString("Appearance", comment: ""), detail: appState.theme.label, color: .aveoGold) {
                showThemePicker = true
            }

            settingsRow(
                icon: "bell.fill",
                label: NSLocalizedString("Notifications", comment: ""),
                detail: notificationManager.remindersEnabled ? notificationManager.formattedReminderTime : NSLocalizedString("Off", comment: ""),
                color: .aveoRetinal
            ) {
                showNotificationPicker = true
            }
        }
    }

    private func settingsRow(icon: String, label: String, detail: String, color: Color = .aveoAccent, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background {
                        RoundedRectangle(cornerRadius: 7).fill(color.opacity(0.1))
                    }

                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.aveoText)

                Spacer()

                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.aveoText3)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.aveoText3)
            }
            .padding(10)
            .glassCard(cornerRadius: 14, padding: 0)
        }
        .buttonStyle(.plain)
    }

    // MARK: – About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT")
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)

            settingsRow(icon: "creditcard.fill", label: NSLocalizedString("Manage Subscription", comment: ""), detail: "", color: .aveoTeal) {
                if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                    openURL(url)
                }
            }

            settingsRow(icon: "doc.plaintext.fill", label: NSLocalizedString("Terms of Service", comment: ""), detail: "") {
                if let url = URL(string: "https://axeo.vision/terms") {
                    openURL(url)
                }
            }

            settingsRow(icon: "lock.shield.fill", label: NSLocalizedString("Privacy Policy", comment: ""), detail: "") {
                showPrivacyPolicy = true
            }

            settingsRow(icon: "doc.text.fill", label: NSLocalizedString("Health Disclaimer", comment: ""), detail: "") {
                showDisclaimer = true
            }

            settingsRow(icon: "star.bubble.fill", label: NSLocalizedString("Rate Axeo", comment: ""), detail: "", color: .aveoGold) {
                requestReview()
            }

            settingsRow(icon: "person.2.fill", label: NSLocalizedString("Refer a Friend", comment: ""), detail: "", color: .aveoSuccess) {
                showReferSheet = true
            }

            Text(appVersion)
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .sheet(isPresented: $showReferSheet) {
            let shareText = NSLocalizedString("Train your eyes daily with Axeo — structured eye exercises and screening tests. https://apps.apple.com/app/axeo", comment: "")
            ShareLink(item: shareText) {
                Text("Share Axeo")
            }
            .presentationDetents([.medium])
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "Axeo v\(version)"
    }

    // MARK: – Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA")
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)

            Button {
                HapticManager.heavy()
                showResetConfirm = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.aveoError)
                        .frame(width: 28, height: 28)
                        .background {
                            RoundedRectangle(cornerRadius: 7).fill(Color.aveoError.opacity(0.1))
                        }

                    Text("Reset All Data")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.aveoError)

                    Spacer()
                }
                .padding(10)
                .glassCard(cornerRadius: 14, padding: 0)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(NSLocalizedString("Reset all data", comment: ""))
            .accessibilityHint(NSLocalizedString("Permanently deletes all sessions, test results, and progress", comment: ""))
        }
    }

    // MARK: – Language Picker

    private struct LanguageOption: Identifiable {
        let id: String   // language code
        let name: String  // native name
        let flag: String  // emoji flag
    }

    private let availableLanguages: [LanguageOption] = [
        LanguageOption(id: "en", name: "English", flag: "🇺🇸"),
        LanguageOption(id: "es", name: "Español", flag: "🇪🇸"),
        LanguageOption(id: "ru", name: "Русский", flag: "🇷🇺"),
        LanguageOption(id: "kk", name: "Қазақша", flag: "🇰🇿"),
    ]

    private var currentLanguageCode: String {
        if let saved = user?.preferredLanguage {
            return saved
        }
        return Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
    }

    private var currentLanguageLabel: String {
        availableLanguages.first { $0.id == currentLanguageCode }?.name ?? "English"
    }

    private var languagePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(availableLanguages) { lang in
                    Button {
                        HapticManager.selection()
                        selectLanguage(lang.id)
                    } label: {
                        HStack(spacing: 12) {
                            Text(lang.flag)
                                .font(.system(size: 28))

                            Text(lang.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.aveoText)

                            Spacer()

                            if lang.id == currentLanguageCode {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.aveoTeal)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(Color.aveoGlass)

                Section {
                    Text("The app will restart to apply the new language.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.aveoText3)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.aveoBg)
            .navigationTitle(NSLocalizedString("Language", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        showLanguagePicker = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func selectLanguage(_ code: String) {
        user?.preferredLanguage = code
        user?.updatedAt = .now
        try? modelContext.save()

        // Apply language override via Apple's standard mechanism
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        showLanguagePicker = false

        // Terminate & relaunch to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            exit(0)
        }
    }

    // MARK: – Theme Picker

    private var themePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(AppState.AppTheme.allCases, id: \.rawValue) { theme in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            appState.theme = theme
                        }
                        HapticManager.selection()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: theme.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(appState.theme == theme ? Color.aveoGold : Color.aveoText3)
                                .frame(width: 32, height: 32)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appState.theme == theme ? Color.aveoGold.opacity(0.12) : Color.aveoGlass)
                                }

                            Text(theme.label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.aveoText)

                            Spacer()

                            if appState.theme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.aveoGold)
                            }
                        }
                        .padding(12)
                        .glassCard(cornerRadius: 14, padding: 0)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .background(Color.aveoBg.ignoresSafeArea())
            .navigationTitle(NSLocalizedString("Appearance", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        showThemePicker = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: – Notification Picker

    private var notificationPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Enable / disable toggle
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.aveoRetinal)
                        .frame(width: 28, height: 28)
                        .background {
                            RoundedRectangle(cornerRadius: 7).fill(Color.aveoRetinal.opacity(0.1))
                        }

                    Text(NSLocalizedString("Daily Reminder", comment: ""))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.aveoText)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { notificationManager.remindersEnabled },
                        set: { newValue in
                            if newValue {
                                Task {
                                    let granted = await notificationManager.requestAuthorization()
                                    await MainActor.run {
                                        notificationManager.remindersEnabled = granted
                                    }
                                }
                            } else {
                                notificationManager.remindersEnabled = false
                            }
                        }
                    ))
                    .tint(Color.aveoTeal)
                    .labelsHidden()
                }
                .padding(12)
                .glassCard(cornerRadius: 14, padding: 0)

                // Time picker (only when enabled)
                if notificationManager.remindersEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("REMINDER TIME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.aveoText3)
                            .kerning(0.8)

                        DatePicker(
                            "",
                            selection: Binding(
                                get: {
                                    var comps = DateComponents()
                                    comps.hour = notificationManager.reminderHour
                                    comps.minute = notificationManager.reminderMinute
                                    return Calendar.current.date(from: comps) ?? .now
                                },
                                set: { newDate in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    notificationManager.reminderHour = comps.hour ?? 9
                                    notificationManager.reminderMinute = comps.minute ?? 0
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxHeight: 150)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 14, padding: 0)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    // Streak reminder toggle
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.aveoWarning)
                            .frame(width: 28, height: 28)
                            .background {
                                RoundedRectangle(cornerRadius: 7).fill(Color.aveoWarning.opacity(0.1))
                            }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(NSLocalizedString("Streak Reminder", comment: ""))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.aveoText)
                            Text(NSLocalizedString("Reminds you at 8 PM if you haven't trained", comment: ""))
                                .font(.system(size: 10))
                                .foregroundStyle(Color.aveoText3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { notificationManager.remindersEnabled },
                            set: { newValue in
                                if newValue {
                                    notificationManager.scheduleStreakReminder()
                                } else {
                                    notificationManager.cancelStreakReminder()
                                }
                            }
                        ))
                        .tint(Color.aveoWarning)
                        .labelsHidden()
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 14, padding: 0)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .background(Color.aveoBg.ignoresSafeArea())
            .navigationTitle(NSLocalizedString("Notifications", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .animation(.spring(duration: 0.3), value: notificationManager.remindersEnabled)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        showNotificationPicker = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: – Photo Handling

    private func loadPhoto(from item: PhotosPickerItem) {
        isLoadingPhoto = true
        Task {
            defer { isLoadingPhoto = false }
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            // Downscale to reasonable avatar size
            guard let uiImage = UIImage(data: data) else { return }
            let maxDim: CGFloat = 400
            let scale = min(maxDim / uiImage.size.width, maxDim / uiImage.size.height, 1.0)
            let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)

            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.jpegData(withCompressionQuality: 0.8) { ctx in
                uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            }

            await MainActor.run {
                user?.profilePhotoData = resized
                user?.updatedAt = .now
                try? modelContext.save()
                HapticManager.success()
            }
        }
    }

    // MARK: – Actions

    private func saveName() {
        let name = nameText.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty {
            user?.displayName = name
            user?.updatedAt = .now
            try? modelContext.save()
        }
        editingName = false
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: Session.self)
            try modelContext.delete(model: VisionTestResult.self)
            try modelContext.delete(model: CourseProgress.self)
            try modelContext.save()
            HapticManager.success()
        } catch {
            print("[Profile] Reset error: \(error)")
        }
    }

    // MARK: – Goal Picker

    private var goalPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ForEach(User.Goal.allCases) { goal in
                    Button {
                        HapticManager.selection()
                        user?.goal = goal
                        user?.updatedAt = .now
                        try? modelContext.save()
                        showGoalPicker = false
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: goal.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(user?.goal == goal ? Color.aveoTeal : Color.aveoText3)
                                .frame(width: 32, height: 32)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(user?.goal == goal ? Color.aveoTeal.opacity(0.12) : Color.aveoGlass)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(goal.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.aveoText)
                                Text(goal.description)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.aveoText3)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if user?.goal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.aveoTeal)
                            }
                        }
                        .padding(12)
                        .glassCard(cornerRadius: 14, padding: 0)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .background(Color.aveoBg.ignoresSafeArea())
            .navigationTitle(NSLocalizedString("Training Goal", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        showGoalPicker = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: – Diagnosis Picker

    private var diagnosisPickerSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(User.Diagnosis.allCases) { diagnosis in
                        Button {
                            HapticManager.selection()
                            user?.diagnosis = diagnosis
                            user?.updatedAt = .now
                            try? modelContext.save()
                            showDiagnosisPicker = false
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: diagnosisIcon(diagnosis))
                                    .font(.system(size: 16))
                                    .foregroundStyle(user?.diagnosis == diagnosis ? Color.aveoAccent : Color.aveoText3)
                                    .frame(width: 28, height: 28)
                                    .background {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(user?.diagnosis == diagnosis ? Color.aveoAccent.opacity(0.12) : Color.aveoGlass)
                                    }

                                Text(diagnosis.displayName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.aveoText)

                                Spacer()

                                if user?.diagnosis == diagnosis {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.aveoAccent)
                                }
                            }
                            .padding(10)
                            .glassCard(cornerRadius: 12, padding: 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .background(Color.aveoBg.ignoresSafeArea())
            .navigationTitle(NSLocalizedString("Eye Condition", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        showDiagnosisPicker = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func diagnosisIcon(_ diagnosis: User.Diagnosis) -> String {
        switch diagnosis {
        case .none:        "checkmark.shield.fill"
        case .myopia:      "eye.fill"
        case .hyperopia:   "eye.trianglebadge.exclamationmark.fill"
        case .astigmatism: "circle.dashed"
        case .presbyopia:  "eyeglasses"
        case .dryEye:      "drop.fill"
        case .other:       "questionmark.circle.fill"
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
        .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
        .preferredColorScheme(.dark)
}
