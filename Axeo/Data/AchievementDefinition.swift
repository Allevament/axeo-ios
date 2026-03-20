import SwiftUI

/// Lightweight achievement definitions — no SwiftData dependency.
/// Unlocked state is computed at read-time from Session / VisionTestResult counts.
struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let tier: Tier
    let requirement: Requirement

    enum Tier: Int, Comparable {
        case bronze, silver, gold, diamond
        static func < (lhs: Tier, rhs: Tier) -> Bool { lhs.rawValue < rhs.rawValue }

        var label: String {
            switch self {
            case .bronze:  "Bronze"
            case .silver:  "Silver"
            case .gold:    "Gold"
            case .diamond: "Diamond"
            }
        }
    }

    enum Requirement {
        case workouts(Int)
        case minutes(Int)
        case streak(Int)
        case exercises(Int)
        case screenings(Int)
    }

    /// Evaluate whether unlocked given aggregate stats.
    func isUnlocked(stats: Stats) -> Bool {
        switch requirement {
        case .workouts(let n):   stats.totalWorkouts >= n
        case .minutes(let n):    stats.totalMinutes >= n
        case .streak(let n):     stats.bestStreak >= n
        case .exercises(let n):  stats.totalExercises >= n
        case .screenings(let n): stats.totalScreenings >= n
        }
    }

    /// 0…1 progress toward the requirement.
    func progress(stats: Stats) -> Double {
        let current: Int
        let target: Int
        switch requirement {
        case .workouts(let n):   current = stats.totalWorkouts;   target = n
        case .minutes(let n):    current = stats.totalMinutes;    target = n
        case .streak(let n):     current = stats.bestStreak;      target = n
        case .exercises(let n):  current = stats.totalExercises;  target = n
        case .screenings(let n): current = stats.totalScreenings; target = n
        }
        guard target > 0 else { return 1 }
        return min(1, Double(current) / Double(target))
    }

    struct Stats {
        var totalWorkouts: Int = 0
        var totalMinutes: Int = 0
        var totalExercises: Int = 0
        var bestStreak: Int = 0
        var totalScreenings: Int = 0
    }
}

// MARK: – Catalogue

extension AchievementDefinition {
    static let all: [AchievementDefinition] = [
        // Workout milestones
        .init(id: "first-workout",   title: "First Steps",       description: "Complete your first workout",     icon: "figure.walk",                      color: .aveoTeal,    tier: .bronze,  requirement: .workouts(1)),
        .init(id: "10-workouts",     title: "Getting Serious",   description: "Complete 10 workouts",            icon: "flame.fill",                       color: .aveoTeal,    tier: .silver,  requirement: .workouts(10)),
        .init(id: "50-workouts",     title: "Committed",         description: "Complete 50 workouts",            icon: "star.fill",                        color: .aveoGold,    tier: .gold,    requirement: .workouts(50)),
        .init(id: "100-workouts",    title: "Centurion",         description: "Complete 100 workouts",           icon: "trophy.fill",                      color: .aveoRetinal, tier: .diamond, requirement: .workouts(100)),

        // Streak milestones
        .init(id: "3-streak",        title: "On a Roll",         description: "Reach a 3-day streak",            icon: "bolt.fill",                        color: .aveoGold,    tier: .bronze,  requirement: .streak(3)),
        .init(id: "7-streak",        title: "Week Warrior",      description: "Reach a 7-day streak",            icon: "bolt.circle.fill",                 color: .aveoGold,    tier: .silver,  requirement: .streak(7)),
        .init(id: "30-streak",       title: "Iron Discipline",   description: "Reach a 30-day streak",           icon: "crown.fill",                       color: .aveoGold,    tier: .diamond, requirement: .streak(30)),

        // Minutes milestones
        .init(id: "60-minutes",      title: "One Hour",          description: "Train for 60 total minutes",      icon: "clock.fill",                       color: .aveoAccent,  tier: .bronze,  requirement: .minutes(60)),
        .init(id: "300-minutes",     title: "Dedicated",         description: "Train for 300 total minutes",     icon: "clock.badge.checkmark.fill",       color: .aveoAccent,  tier: .silver,  requirement: .minutes(300)),
        .init(id: "1000-minutes",    title: "Marathon Eyes",     description: "Train for 1000 total minutes",    icon: "hourglass.badge.plus",             color: .aveoAccent,  tier: .gold,    requirement: .minutes(1000)),

        // Exercise milestones
        .init(id: "50-exercises",    title: "Warming Up",        description: "Complete 50 exercises",            icon: "eye.fill",                         color: .aveoSuccess, tier: .bronze,  requirement: .exercises(50)),
        .init(id: "200-exercises",   title: "Sharp Focus",       description: "Complete 200 exercises",           icon: "eye.circle.fill",                  color: .aveoSuccess, tier: .silver,  requirement: .exercises(200)),

        // Screening milestones
        .init(id: "first-screening", title: "Self-Aware",        description: "Complete your first screening",   icon: "checklist",                        color: .aveoData,    tier: .bronze,  requirement: .screenings(1)),
        .init(id: "10-screenings",   title: "Vigilant",          description: "Complete 10 screenings",          icon: "checklist.checked",                color: .aveoData,    tier: .silver,  requirement: .screenings(10)),
    ]
}
