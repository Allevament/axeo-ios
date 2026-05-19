import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var page = 0
    @State private var selectedGoal: User.Goal = .prevention
    @State private var selectedDiagnosis: User.Diagnosis? = nil
    @State private var userName = ""
    @State private var dragOffset: CGSize = .zero
    @State private var showOnboardingPaywall = false

    private let totalPages = 5

    var body: some View {
        if showOnboardingPaywall {
            OnboardingPaywallView(goal: selectedGoal) {
                finalizeOnboarding()
            }
        } else {
            ZStack {
                // Radial gradient background
                RadialGradient(
                    colors: [Color.aveoAccent.opacity(0.04), Color.aveoBg],
                    center: .center,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()

                Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Skip
                    HStack {
                        Spacer()
                        if page < 3 {
                            Button {
                                HapticManager.soft()
                                withAnimation(.spring(duration: 0.4)) { page = 3 }
                            } label: {
                                Text("Skip")
                                    .font(.aveoCaption)
                                    .foregroundStyle(Color.aveoText3)
                            }
                            .padding(.trailing, 24)
                            .padding(.top, 12)
                        }
                    }

                    // Content
                    TabView(selection: $page) {
                        welcomePage1.tag(0)
                        welcomePage2.tag(1)
                        welcomePage3.tag(2)
                        goalPage.tag(3)
                        diagnosisPage.tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(duration: 0.5, bounce: 0.15), value: page)

                    // Bottom
                    bottomSection
                }
            }
        }
    }

    // MARK: – Welcome Pages with Brand Icons

    private var welcomePage1: some View {
        OnboardingBrandPage(
            brandIcon: .landoltRing,
            iconAnimation: .rotating,
            title: "Daily\nEye Training",
            subtitle: "17 structured exercises for general eye wellness. Build a daily routine to give your eyes the rest and movement they need."
        )
    }

    private var welcomePage2: some View {
        OnboardingBrandPage(
            brandIcon: .amslerGrid,
            iconAnimation: .drawing,
            title: "Track Your\nProgress",
            subtitle: "Streaks, stats, and vision screening — all in one place. See your improvement over days and weeks."
        )
    }

    private var welcomePage3: some View {
        OnboardingBrandPage(
            brandIcon: .duochrome,
            iconAnimation: .shimmer,
            title: "Private &\nSecure",
            subtitle: "All data stays on your device. No accounts, no cloud uploads, no tracking. Your eyes, your data."
        )
    }

    // MARK: – Goal Page

    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What's your main goal?")
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)
                .multilineTextAlignment(.center)

            Text("We'll personalize your daily workouts")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)

            VStack(spacing: 12) {
                ForEach(User.Goal.allCases) { goal in
                    goalOption(goal)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func goalOption(_ goal: User.Goal) -> some View {
        let isSelected = selectedGoal == goal

        return Button {
            HapticManager.selection()
            withAnimation(.spring(duration: 0.25)) {
                selectedGoal = goal
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: goal.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.aveoAccent : Color.aveoText3)
                    .frame(width: 44, height: 44)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.aveoAccent.opacity(0.12) : Color.aveoText3.opacity(0.08))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.displayName)
                        .font(.aveoHeadline)
                        .foregroundStyle(isSelected ? Color.aveoText : Color.aveoText2)
                    Text(goal.description)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.aveoText3)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.aveoRetinal)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aveoAccent.opacity(0.06))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aveoGlass)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Color.aveoAccent.opacity(0.3) : Color.aveoGlassBorder, lineWidth: 0.5)
            }
            .shadow(color: isSelected ? Color.aveoAccent.opacity(0.08) : .clear, radius: 12)
            .aveoShadowMd()
        }
        .buttonStyle(.plain)
    }

    // MARK: – Diagnosis Page

    private var diagnosisPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Any known eye condition?")
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)
                .multilineTextAlignment(.center)

            Text("Optional — helps us customize exercises")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)

            // Name field
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Name")
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)

                TextField("", text: $userName, prompt: Text("Guest").foregroundStyle(Color.aveoText3))
                    .font(.aveoBody)
                    .foregroundStyle(Color.aveoText)
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).fill(Color.aveoGlass)
                            .allowsHitTesting(false)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
                            .allowsHitTesting(false)
                    }
            }
            .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    diagnosisChip(nil, label: NSLocalizedString("None", comment: ""))
                    ForEach(User.Diagnosis.allCases.filter { $0 != .none }) { diag in
                        diagnosisChip(diag, label: diag.displayName)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Mini disclaimer shown only when a condition is selected.
            if selectedDiagnosis != nil && selectedDiagnosis != User.Diagnosis.none {
                Text(NSLocalizedString("Used only to vary your routine. It is not a treatment plan or a recommendation for your condition. Consult an eye-care professional before starting.", comment: ""))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.aveoText3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .transition(.opacity)
            }

            Spacer()
        }
    }

    private func diagnosisChip(_ diagnosis: User.Diagnosis?, label: String) -> some View {
        let isSelected = selectedDiagnosis == diagnosis

        return Button {
            HapticManager.selection()
            withAnimation(.spring(duration: 0.2)) {
                selectedDiagnosis = diagnosis
            }
        } label: {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Color.aveoAccent : Color.aveoText2)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule().fill(Color.aveoAccent.opacity(0.12))
                    } else {
                        Capsule().fill(.ultraThinMaterial)
                    }
                }
                .overlay {
                    if !isSelected {
                        Capsule().fill(Color.aveoGlass)
                    }
                }
                .overlay {
                    Capsule().strokeBorder(isSelected ? Color.aveoAccent.opacity(0.3) : Color.aveoGlassBorder, lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: – Bottom

    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Bar indicators instead of dots
            HStack(spacing: 6) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Color.aveoAccent : Color.aveoText3.opacity(0.2))
                        .frame(width: i == page ? 24 : 8, height: 4)
                        .animation(.spring(duration: 0.3), value: page)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Page \(page + 1) of \(totalPages)")

            // Button
            Button {
                HapticManager.medium()
                if page < totalPages - 1 {
                    withAnimation(.spring(duration: 0.4)) { page += 1 }
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(page < totalPages - 1 ? "Continue" : "Let's Start")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.aveoBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient.aveoAccentGradient,
                        in: Capsule()
                    )
                    .shadow(color: Color.aveoAccent.opacity(0.3), radius: 16, y: 4)
            }
            .padding(.horizontal, 24)
            .accessibilityLabel(page < totalPages - 1 ? "Continue to next step" : "Start using Axeo")

            if page == totalPages - 1 {
                Text("No account needed · 100% on-device")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.aveoText3)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: – Complete

    private func completeOnboarding() {
        // Create user first, then show onboarding paywall
        let name = userName.trimmingCharacters(in: .whitespaces)
        let user = User(
            displayName: name.isEmpty ? NSLocalizedString("Guest", comment: "") : name,
            email: "",
            diagnosis: selectedDiagnosis,
            goal: selectedGoal
        )
        modelContext.insert(user)
        try? modelContext.save()
        appState.currentUser = user

        // Show the onboarding paywall before entering the app
        withAnimation(.spring(duration: 0.4)) {
            showOnboardingPaywall = true
        }
    }

    private func finalizeOnboarding() {
        appState.hasCompletedOnboarding = true
        HapticManager.success()
    }
}

// MARK: – Onboarding Brand Page

struct OnboardingBrandPage: View {
    let brandIcon: BrandIcon.Icon
    let iconAnimation: IconAnimation
    let title: String
    let subtitle: String

    enum IconAnimation { case rotating, drawing, shimmer }

    @State private var appeared = false
    @State private var rotationAngle: Double = 0
    @State private var drawProgress: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Brand icon hero with glow
            ZStack {
                // Glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.aveoAccent.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                BrandIcon(icon: brandIcon, isActive: true, size: 80)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
            }
            .rotation3DEffect(
                .degrees(appeared ? 0 : 8),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )

            Text(title)
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)
                .multilineTextAlignment(.center)
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)

            Text(subtitle)
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .offset(y: appeared ? 0 : 16)
                .opacity(appeared ? 1 : 0)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
        .preferredColorScheme(.dark)
}
