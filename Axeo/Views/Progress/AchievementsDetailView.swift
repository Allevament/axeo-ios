import SwiftUI

struct AchievementsDetailView: View {
    let stats: AchievementDefinition.Stats

    @State private var appeared = false
    @State private var ringsAnimated = false

    private var unlocked: [AchievementDefinition] {
        AchievementDefinition.all.filter { $0.isUnlocked(stats: stats) }
    }

    private var locked: [AchievementDefinition] {
        AchievementDefinition.all.filter { !$0.isUnlocked(stats: stats) }
    }

    // Category ring data
    private var categoryRings: [CategoryRing] {
        [
            CategoryRing(
                label: NSLocalizedString("Workouts", comment: ""),
                icon: "figure.run",
                color: .aveoTeal,
                progress: categoryProgress(for: .workouts)
            ),
            CategoryRing(
                label: NSLocalizedString("Streaks", comment: ""),
                icon: "flame.fill",
                color: .aveoGold,
                progress: categoryProgress(for: .streaks)
            ),
            CategoryRing(
                label: NSLocalizedString("Minutes", comment: ""),
                icon: "timer",
                color: .aveoAccent,
                progress: categoryProgress(for: .minutes)
            ),
            CategoryRing(
                label: NSLocalizedString("Exercises", comment: ""),
                icon: "eye.fill",
                color: .aveoSuccess,
                progress: categoryProgress(for: .exercises)
            ),
            CategoryRing(
                label: NSLocalizedString("Screenings", comment: ""),
                icon: "waveform.path.ecg.rectangle.fill",
                color: .aveoData,
                progress: categoryProgress(for: .screenings)
            ),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Oura-style concentric rings
                ringsSection

                // Trophy shelf
                shelfSection

                // Locked section
                if !locked.isEmpty {
                    lockedSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AmbientBackground())
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !appeared else { return }
            withAnimation(.spring(duration: 0.6)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(duration: 1.0, bounce: 0.1)) {
                    ringsAnimated = true
                }
            }
        }
    }

    // MARK: – Concentric Rings (Oura-style)

    private var ringsSection: some View {
        VStack(spacing: 12) {
            ZStack {
                ForEach(Array(categoryRings.enumerated()), id: \.offset) { idx, ring in
                    let size: CGFloat = 160 - CGFloat(idx) * 26
                    let lineWidth: CGFloat = 8

                    // Track
                    Circle()
                        .stroke(ring.color.opacity(0.1), lineWidth: lineWidth)
                        .frame(width: size, height: size)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: ringsAnimated ? ring.progress : 0)
                        .stroke(
                            AngularGradient(
                                colors: [ring.color.opacity(0.6), ring.color, ring.color],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(-90))

                    // End-cap glow dot
                    if ring.progress > 0.02 {
                        Circle()
                            .fill(ring.color)
                            .frame(width: lineWidth + 2, height: lineWidth + 2)
                            .shadow(color: ring.color.opacity(0.6), radius: 4)
                            .offset(y: -(size / 2))
                            .rotationEffect(.degrees((ringsAnimated ? ring.progress : 0) * 360 - 90))
                    }
                }
            }
            .frame(width: 160, height: 160)
            .padding(.top, 8)

            // Legend
            HStack(spacing: 12) {
                ForEach(Array(categoryRings.enumerated()), id: \.offset) { _, ring in
                    VStack(spacing: 2) {
                        Circle()
                            .fill(ring.color)
                            .frame(width: 6, height: 6)
                        Text(ring.label)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(Color.aveoText3)
                        Text("\(Int(ring.progress * 100))%")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(ring.color)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 20, padding: 0)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    // MARK: – Trophy Shelf

    private var shelfSection: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ]

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("TROPHY SHELF")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.aveoText3)
                    .kerning(0.8)
                Spacer()
                Text("\(unlocked.count)/\(AchievementDefinition.all.count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.aveoGold)
            }

            if unlocked.isEmpty {
                emptyShelf
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(unlocked.enumerated()), id: \.element.id) { idx, achievement in
                        trophyCard(achievement, index: idx)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(duration: 0.5).delay(0.15), value: appeared)
    }

    private func trophyCard(_ achievement: AchievementDefinition, index: Int) -> some View {
        VStack(spacing: 6) {
            // Trophy icon on glass pedestal
            ZStack {
                // Shelf/pedestal
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                achievement.color.opacity(0.15),
                                achievement.color.opacity(0.05),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(spacing: 4) {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [achievement.color, achievement.color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: achievement.color.opacity(0.3), radius: 6)

                    // Tier indicator
                    HStack(spacing: 2) {
                        ForEach(0..<tierStars(achievement.tier), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 5))
                                .foregroundStyle(achievement.color)
                        }
                    }
                }
            }
            .frame(height: 72)
            .glassCard(cornerRadius: 12, padding: 0)

            Text(achievement.title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.aveoText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(achievement.tier.label)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(achievement.color)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(duration: 0.4).delay(Double(index) * 0.06 + 0.2), value: appeared)
    }

    private var emptyShelf: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy")
                .font(.system(size: 32))
                .foregroundStyle(Color.aveoText3.opacity(0.25))
            Text("Complete workouts and screenings\nto earn your first trophy")
                .font(.system(size: 11))
                .foregroundStyle(Color.aveoText3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .glassCard(cornerRadius: 16, padding: 0)
    }

    // MARK: – Locked Achievements

    private var lockedSection: some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
        ]

        return VStack(alignment: .leading, spacing: 10) {
            Text("LOCKED")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(locked) { achievement in
                    let pct = achievement.progress(stats: stats)
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.aveoText3.opacity(0.06))
                                .frame(width: 44, height: 44)

                            // Progress ring behind locked icon
                            Circle()
                                .trim(from: 0, to: ringsAnimated ? pct : 0)
                                .stroke(achievement.color.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 44, height: 44)
                                .rotationEffect(.degrees(-90))

                            Image(systemName: achievement.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.aveoText3.opacity(0.25))

                            // Lock badge
                            Image(systemName: "lock.fill")
                                .font(.system(size: 7))
                                .foregroundStyle(Color.aveoText3.opacity(0.5))
                                .offset(x: 14, y: 14)
                        }

                        Text(achievement.title)
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(Color.aveoText3.opacity(0.6))
                            .lineLimit(1)

                        Text("\(Int(pct * 100))%")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.aveoText3.opacity(0.4))
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(.spring(duration: 0.5).delay(0.25), value: appeared)
    }

    // MARK: – Helpers

    private func tierStars(_ tier: AchievementDefinition.Tier) -> Int {
        switch tier {
        case .bronze:  1
        case .silver:  2
        case .gold:    3
        case .diamond: 4
        }
    }

    private enum Category {
        case workouts, streaks, minutes, exercises, screenings
    }

    private func categoryProgress(for category: Category) -> Double {
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
        case .screenings:
            achievements = AchievementDefinition.all.filter {
                if case .screenings = $0.requirement { return true }; return false
            }
        }

        guard !achievements.isEmpty else { return 0 }
        let totalProgress = achievements.reduce(0.0) { $0 + $1.progress(stats: stats) }
        return totalProgress / Double(achievements.count)
    }

    struct CategoryRing {
        let label: String
        let icon: String
        let color: Color
        let progress: Double
    }
}

#Preview {
    NavigationStack {
        AchievementsDetailView(stats: .init(
            totalWorkouts: 12,
            totalMinutes: 180,
            totalExercises: 75,
            bestStreak: 5,
            totalScreenings: 3
        ))
    }
    .preferredColorScheme(.dark)
}
