import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Session.endedAt, order: .reverse) private var allSessions: [Session]
    @Query(sort: \VisionTestResult.timestamp, order: .reverse) private var testResults: [VisionTestResult]

    private var user: User? { appState.currentUser }

    private var userSessions: [Session] {
        guard let uid = user?.id else { return [] }
        return allSessions.filter { $0.userId == uid }
    }

    private var completedSessions: [Session] {
        userSessions.filter(\.completed)
    }

    @State private var appeared = false
    @State private var ringsAnimated = false
    @State private var showAchievements = false
    @State private var showExport = false

    private var achievementStats: AchievementDefinition.Stats {
        let totalMinutes = completedSessions.reduce(0) { $0 + $1.totalDurationSec } / 60
        let totalExercises = completedSessions.reduce(0) { $0 + $1.exerciseCount }
        return .init(
            totalWorkouts: completedSessions.count,
            totalMinutes: totalMinutes,
            totalExercises: totalExercises,
            bestStreak: calculateBestStreak(),
            totalScreenings: testResults.count
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerSection
                achievementsHeroBento
                streakBento
                activityBento
                exportBento
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AmbientBackground())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !appeared else { return }
            guard !UIAccessibility.isReduceMotionEnabled else {
                appeared = true
                ringsAnimated = true
                return
            }
            withAnimation(.spring(duration: 0.5)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(duration: 1.0, bounce: 0.1)) {
                    ringsAnimated = true
                }
            }
        }
        .navigationDestination(isPresented: $showAchievements) {
            AchievementsDetailView(stats: achievementStats)
        }
        .navigationDestination(isPresented: $showExport) {
            ExportProgressView()
        }
    }

    // MARK: – Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("My Progress")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
            Text(insightText)
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .modifier(BentoIn(index: 0, appeared: appeared))
    }

    private var insightText: String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        guard let lastWeekStart = cal.date(byAdding: .day, value: -14, to: today),
              let thisWeekStart = cal.date(byAdding: .day, value: -7, to: today) else {
            return NSLocalizedString("Track your eye health progress", comment: "")
        }
        let lastWeekCount = completedSessions.filter { $0.startedAt >= lastWeekStart && $0.startedAt < thisWeekStart }.count
        let thisWeekCount = completedSessions.filter { $0.startedAt >= thisWeekStart }.count

        if lastWeekCount == 0 && thisWeekCount == 0 {
            return NSLocalizedString("Start training to track your progress", comment: "")
        } else if lastWeekCount == 0 {
            return String(format: NSLocalizedString("Great start — %d workout(s) this week!", comment: ""), thisWeekCount)
        } else if thisWeekCount > lastWeekCount {
            return String(format: NSLocalizedString("You've trained %d× more than last week", comment: ""), thisWeekCount - lastWeekCount)
        } else if thisWeekCount == lastWeekCount {
            return NSLocalizedString("Consistent! Same pace as last week", comment: "")
        } else {
            return String(format: NSLocalizedString("Keep it up — %d workout(s) this week", comment: ""), thisWeekCount)
        }
    }

    // MARK: – Large Achievements Hero Bento (with activity ring + all-time stats)

    private var achievementsHeroBento: some View {
        let stats = achievementStats
        let unlocked = AchievementDefinition.all.filter { $0.isUnlocked(stats: stats) }
        let unlockedCount = unlocked.count
        let totalCount = AchievementDefinition.all.count
        let totalMinutes = completedSessions.reduce(0) { $0 + $1.totalDurationSec } / 60
        let totalExercises = completedSessions.reduce(0) { $0 + $1.exerciseCount }

        return Button {
            HapticManager.selection()
            showAchievements = true
        } label: {
            VStack(spacing: 14) {
                // Top: concentric rings + achievement count
                HStack(spacing: 16) {
                    // Large Oura-style rings
                    ZStack {
                        // Ring 1 – workouts (outermost)
                        ringView(progress: ringProgress(for: .workouts), color: .aveoTeal, size: 80, lineWidth: 6)
                        // Ring 2 – streaks
                        ringView(progress: ringProgress(for: .streaks), color: .aveoGold, size: 60, lineWidth: 5)
                        // Ring 3 – minutes
                        ringView(progress: ringProgress(for: .minutes), color: .aveoAccent, size: 42, lineWidth: 4)
                        // Ring 4 – exercises (innermost)
                        ringView(progress: ringProgress(for: .exercises), color: .aveoSuccess, size: 26, lineWidth: 3)
                    }
                    .frame(width: 86, height: 86)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text("Achievements")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.aveoText)
                            Spacer()
                            Text("\(unlockedCount)/\(totalCount)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color.aveoGold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule().fill(Color.aveoGold.opacity(0.1))
                                }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.aveoText3)
                        }

                        // Ring legend
                        HStack(spacing: 8) {
                            ringLegend(label: "Work", color: .aveoTeal)
                            ringLegend(label: "Streak", color: .aveoGold)
                            ringLegend(label: "Time", color: .aveoAccent)
                            ringLegend(label: "Eyes", color: .aveoSuccess)
                        }

                        // Mini trophy row – last 5 unlocked
                        if !unlocked.isEmpty {
                            HStack(spacing: -4) {
                                ForEach(unlocked.suffix(5)) { a in
                                    ZStack {
                                        Circle()
                                            .fill(a.color.opacity(0.15))
                                            .frame(width: 22, height: 22)
                                        Circle()
                                            .strokeBorder(Color.aveoBg.opacity(0.8), lineWidth: 1.5)
                                            .frame(width: 22, height: 22)
                                        Image(systemName: a.icon)
                                            .font(.system(size: 9))
                                            .foregroundStyle(a.color)
                                    }
                                }
                                if unlocked.count > 5 {
                                    ZStack {
                                        Circle()
                                            .fill(Color.aveoText3.opacity(0.1))
                                            .frame(width: 22, height: 22)
                                        Text("+\(unlocked.count - 5)")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(Color.aveoText3)
                                    }
                                }
                            }
                        }
                    }
                }

                // All-time stats row
                HStack(spacing: 8) {
                    miniStat(value: "\(completedSessions.count)", label: "Workouts", icon: "figure.run", color: .aveoTeal)
                    miniStat(value: "\(totalMinutes)", label: "Minutes", icon: "timer", color: .aveoAccent)
                    miniStat(value: "\(totalExercises)", label: "Exercises", icon: "eye.fill", color: .aveoSuccess)
                    miniStat(value: "\(testResults.count)", label: "Tests", icon: "waveform.path.ecg", color: .aveoData)
                }
            }
            .padding(14)
            .glassCard(cornerRadius: 18, padding: 0)
        }
        .buttonStyle(.pressScale)
        .modifier(BentoIn(index: 1, appeared: appeared))
    }

    private func ringView(progress: Double, color: Color, size: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.1), lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: ringsAnimated ? progress : 0)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.6), color, color],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
        }
    }

    private func ringLegend(label: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
    }

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
            Text(label)
                .font(.system(size: 7, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.04))
        }
    }

    private enum AchievementCategory {
        case workouts, streaks, minutes, exercises
    }

    private func ringProgress(for category: AchievementCategory) -> Double {
        let achievements: [AchievementDefinition]
        switch category {
        case .workouts:
            achievements = AchievementDefinition.all.filter {
                if case .workouts = $0.requirement { return true }; return false
            }
        case .streaks:
            achievements = AchievementDefinition.all.filter {
                if case .streak = $0.requirement { return true }; return false
            }
        case .minutes:
            achievements = AchievementDefinition.all.filter {
                if case .minutes = $0.requirement { return true }; return false
            }
        case .exercises:
            achievements = AchievementDefinition.all.filter {
                if case .exercises = $0.requirement { return true }; return false
            }
        }
        guard !achievements.isEmpty else { return 0 }
        let stats = achievementStats
        return achievements.reduce(0.0) { $0 + $1.progress(stats: stats) } / Double(achievements.count)
    }

    // MARK: – Streak Bento (two cards side by side)

    private var streakBento: some View {
        let streak = calculateStreak()
        let best = calculateBestStreak()

        return HStack(spacing: 10) {
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.linearGradient(
                        colors: [.aveoRetinal, .aveoGold],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                Text("\(streak)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.aveoText)
                    .contentTransition(.numericText())
                Text(NSLocalizedString("Current Streak", comment: ""))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.aveoText3)
                    .textCase(.uppercase)
                Text(streak == 1 ? NSLocalizedString("day", comment: "") : NSLocalizedString("days", comment: ""))
                    .font(.system(size: 9))
                    .foregroundStyle(Color.aveoText3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCard(cornerRadius: 16, padding: 0)

            VStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.linearGradient(
                        colors: [.aveoGold, Color(hex: 0xD4A017)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                Text("\(best)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.aveoText)
                    .contentTransition(.numericText())
                Text(NSLocalizedString("Best Streak", comment: ""))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.aveoText3)
                    .textCase(.uppercase)
                Text(best == 1 ? NSLocalizedString("day", comment: "") : NSLocalizedString("days", comment: ""))
                    .font(.system(size: 9))
                    .foregroundStyle(Color.aveoText3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCard(cornerRadius: 16, padding: 0)
        }
        .modifier(BentoIn(index: 2, appeared: appeared))
    }

    // MARK: – Activity Chart

    private var activityBento: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ACTIVITY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            WeeklyBarChart(sessions: completedSessions)
        }
        .padding(14)
        .glassCard(cornerRadius: 16, padding: 0)
        .modifier(BentoIn(index: 3, appeared: appeared))
    }

    // MARK: – Export

    private var exportBento: some View {
        Button {
            HapticManager.selection()
            showExport = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.linearGradient(
                        colors: [.aveoTeal, .aveoAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 26, height: 26)
                    .background {
                        RoundedRectangle(cornerRadius: 7).fill(Color.aveoTeal.opacity(0.1))
                    }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Export Progress")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.aveoText)
                    Text("Share or save your training data")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.aveoText3)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.aveoText3)
            }
            .padding(10)
            .glassCard(cornerRadius: 14, padding: 0)
        }
        .buttonStyle(.pressScale)
        .modifier(BentoIn(index: 4, appeared: appeared))
    }

    // MARK: – Streak Calculations

    private func calculateStreak() -> Int {
        guard !completedSessions.isEmpty else { return 0 }
        let cal = Calendar.current
        var count = 0
        var day = cal.startOfDay(for: .now)

        while true {
            let nextDay = cal.date(byAdding: .day, value: 1, to: day)!
            let has = completedSessions.contains { $0.startedAt >= day && $0.startedAt < nextDay }
            if has {
                count += 1
                day = cal.date(byAdding: .day, value: -1, to: day)!
            } else {
                break
            }
        }
        return count
    }

    private func calculateBestStreak() -> Int {
        guard !completedSessions.isEmpty else { return 0 }
        let cal = Calendar.current
        let sorted = completedSessions.sorted { $0.startedAt < $1.startedAt }

        var best = 0
        var current = 1
        var lastDay = cal.startOfDay(for: sorted[0].startedAt)

        for session in sorted.dropFirst() {
            let sessionDay = cal.startOfDay(for: session.startedAt)
            if sessionDay == lastDay { continue }
            let diff = cal.dateComponents([.day], from: lastDay, to: sessionDay).day ?? 0
            if diff == 1 {
                current += 1
            } else {
                best = max(best, current)
                current = 1
            }
            lastDay = sessionDay
        }
        return max(best, current)
    }
}

// MARK: – Bento Stagger Animation

private struct BentoIn: ViewModifier {
    let index: Int
    let appeared: Bool

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 18)
            .opacity(appeared ? 1 : 0)
            .animation(
                .spring(duration: 0.45, bounce: 0.12).delay(Double(index) * 0.05),
                value: appeared
            )
    }
}

#Preview {
    NavigationStack {
        ProgressDashboardView()
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.light)
}
