import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.endedAt, order: .reverse) private var allSessions: [Session]

    @State private var sessionExercises: [Int] = QuickSession.defaultIndices
    @State private var showProfile = false
    @State private var showActiveSession = false
    @State private var showPaywall = false
    @State private var sectionsAppeared = false
    @State private var selectedExercise: ExerciseDefinition?

    // MARK: – Computed

    private var user: User? { appState.currentUser }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let name = user?.displayName ?? NSLocalizedString("Guest", comment: "")
        switch hour {
        case 5..<12:  return String(format: NSLocalizedString("Good morning, %@", comment: ""), name)
        case 12..<17: return String(format: NSLocalizedString("Good afternoon, %@", comment: ""), name)
        case 17..<22: return String(format: NSLocalizedString("Good evening, %@", comment: ""), name)
        default:      return String(format: NSLocalizedString("Hello, %@", comment: ""), name)
        }
    }

    private var todaySessions: [Session] {
        let start = Calendar.current.startOfDay(for: .now)
        return allSessions.filter { $0.startedAt >= start && $0.completed }
    }

    private var streak: Int {
        guard let uid = user?.id else { return 0 }
        let userSessions = allSessions.filter { $0.userId == uid && $0.completed }
        guard !userSessions.isEmpty else { return 0 }

        var count = 0
        var day = Calendar.current.startOfDay(for: .now)
        let cal = Calendar.current

        while true {
            let nextDay = cal.date(byAdding: .day, value: 1, to: day)!
            let hasSession = userSessions.contains { $0.startedAt >= day && $0.startedAt < nextDay }
            if hasSession {
                count += 1
                day = cal.date(byAdding: .day, value: -1, to: day)!
            } else {
                break
            }
        }
        return count
    }

    private var todayStats: (workouts: Int, focusScore: Int, minutes: Int, exercises: Int) {
        let sessions = todaySessions
        let workouts = sessions.count
        let totalSec = sessions.reduce(0) { $0 + $1.totalDurationSec }
        let totalEx = sessions.reduce(0) { $0 + $1.exerciseCount }
        let accValues = sessions.compactMap(\.accuracy)
        let avgAcc = accValues.isEmpty ? 0 : accValues.reduce(0, +) / accValues.count
        return (workouts, avgAcc, totalSec / 60, totalEx)
    }

    private var recommendations: [ExerciseDefinition] {
        sessionExercises.prefix(3).compactMap { ExerciseDefinition[$0] }
    }

    private var estimatedMinutes: Int {
        let totalSec = sessionExercises.compactMap { ExerciseDefinition[$0]?.duration }.reduce(0, +)
        return max(1, totalSec / 60)
    }

    // MARK: – Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                    .offset(y: sectionsAppeared ? 0 : 20)
                    .opacity(sectionsAppeared ? 1 : 0)

                if streak > 0 {
                    streakBanner
                        .offset(y: sectionsAppeared ? 0 : 20)
                        .opacity(sectionsAppeared ? 1 : 0)
                        .animation(.spring(duration: 0.5).delay(0.1), value: sectionsAppeared)
                }

                quickSessionSection
                    .offset(y: sectionsAppeared ? 0 : 24)
                    .opacity(sectionsAppeared ? 1 : 0)
                    .animation(.spring(duration: 0.5).delay(0.15), value: sectionsAppeared)

                recommendationsSection
                    .offset(y: sectionsAppeared ? 0 : 24)
                    .opacity(sectionsAppeared ? 1 : 0)
                    .animation(.spring(duration: 0.5).delay(0.25), value: sectionsAppeared)

                todayActivitySection
                    .offset(y: sectionsAppeared ? 0 : 24)
                    .opacity(sectionsAppeared ? 1 : 0)
                    .animation(.spring(duration: 0.5).delay(0.35), value: sectionsAppeared)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background { AmbientBackground() }
        .navigationBarHidden(true)
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else {
                sectionsAppeared = true
                return
            }
            withAnimation(.spring(duration: 0.5)) {
                sectionsAppeared = true
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .navigationDestination(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        .task {
            buildSession()
        }
    }

    // MARK: – Sections

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.aveoTitle)
                    .foregroundStyle(Color.aveoText)

                if let goal = user?.goal {
                    MarqueeText(goal.description,
                                font: .system(size: 10, weight: .medium),
                                foregroundColor: Color.aveoText3,
                                speed: 25)
                }
            }

            Spacer(minLength: 12)

            Button {
                showProfile = true
                HapticManager.light()
            } label: {
                profileAvatar
            }
            .accessibilityLabel("Profile")
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var profileAvatar: some View {
        if let data = user?.profilePhotoData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(Color.aveoAccent.opacity(0.3), lineWidth: 1.5)
                }
        } else {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.aveoAccent.opacity(0.2), Color.aveoAccent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)

                Text(avatarInitials)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.aveoAccent)
            }
            .overlay {
                Circle().strokeBorder(Color.aveoAccent.opacity(0.2), lineWidth: 1)
            }
        }
    }

    private var avatarInitials: String {
        let name = user?.displayName ?? "G"
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }

    private var streakBanner: some View {
        HStack {
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                Text(String(format: NSLocalizedString("%d-day streak", comment: ""), streak))
            }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.aveoGold)
            Spacer()
        }
        .padding(.vertical, 6)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .overlay { Capsule().fill(Color.aveoGold.opacity(0.08)) }
        }
        .overlay {
            Capsule().strokeBorder(Color.aveoGold.opacity(0.15), lineWidth: 0.5)
        }
        .accessibilityLabel("\(streak) day streak")
    }

    private var quickSessionSection: some View {
        QuickSessionCard(
            exerciseCount: sessionExercises.count,
            estimatedMinutes: estimatedMinutes
        ) {
            if appState.shouldShowSessionGate {
                showPaywall = true
            } else {
                showActiveSession = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $showActiveSession) {
            let exercises = sessionExercises.compactMap { ExerciseDefinition[$0] }
            ExerciseActiveView(
                exercises: exercises,
                sessionType: .quick,
                courseId: nil
            )
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recommended for You")
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                    Text("based on your goal & condition")
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                Spacer()
                Button {
                    HapticManager.light()
                    buildSession()
                } label: {
                    Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoTeal)
                }
            }

            ForEach(Array(recommendations.enumerated()), id: \.element.id) { idx, exercise in
                let done = todaySessions.contains { $0.exerciseIndices.contains(exercise.index) }
                RecommendationRow(exercise: exercise, rank: idx + 1, isDone: done) {
                    selectedExercise = exercise
                }
            }
        }
    }

    private var todayActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Activity")
                    .font(.aveoHeadline)
                    .foregroundStyle(Color.aveoText)
                Text("updates after each session")
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
            }

            let stats = todayStats
            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                StatCardView(label: NSLocalizedString("Workouts", comment: ""), value: stats.workouts, suffix: "", color: .aveoTeal)
                StatCardView(label: NSLocalizedString("Focus Score", comment: ""), value: stats.focusScore, suffix: "%", color: .aveoAccent)
                StatCardView(label: NSLocalizedString("Time", comment: ""), value: stats.minutes, suffix: NSLocalizedString("m", comment: "minutes abbreviation"), color: .aveoGold)
                StatCardView(label: NSLocalizedString("Exercises", comment: ""), value: stats.exercises, suffix: "", color: .aveoSuccess)
            }
        }
    }

    // MARK: – Helpers

    private func buildSession() {
        guard let user else {
            sessionExercises = QuickSession.defaultIndices
            return
        }
        let recentIndices = Set(todaySessions.flatMap(\.exerciseIndices))
        sessionExercises = QuickSession.build(
            goal: user.goal,
            diagnosis: user.diagnosis,
            isPremium: appState.isPremium,
            recentIndices: recentIndices
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
