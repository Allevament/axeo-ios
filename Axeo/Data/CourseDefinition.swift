import SwiftUI

// MARK: – Course Definition

struct CourseDefinition: Identifiable {
    let id: String               // e.g. "screen-warrior"
    let name: String
    let subtitle: String
    let description: String
    let durationDays: Int
    let difficulty: Difficulty
    let icon: String             // SF Symbol
    let color: Color
    let badges: [String]
    let dailyPlan: [DayPlan]

    enum Difficulty: String {
        case beginner, intermediate, advanced

        var label: String {
            switch self {
            case .beginner:     NSLocalizedString("Beginner", comment: "")
            case .intermediate: NSLocalizedString("Intermediate", comment: "")
            case .advanced:     NSLocalizedString("Advanced", comment: "")
            }
        }

        var color: Color {
            switch self {
            case .beginner:     .aveoSuccess
            case .intermediate: .aveoGold
            case .advanced:     .aveoRetinal
            }
        }
    }

    struct DayPlan: Identifiable {
        let day: Int
        let title: String
        let exerciseIndices: [Int]
        let restDay: Bool

        var id: Int { day }

        var exercises: [ExerciseDefinition] {
            exerciseIndices.compactMap { ExerciseDefinition[$0] }
        }

        var estimatedMinutes: Int {
            exercises.reduce(0) { $0 + $1.duration } / 60
        }
    }
}

// MARK: – All Courses

extension CourseDefinition {
    static let all: [CourseDefinition] = [
        screenWarrior,
        visionBuilder,
        dryEyeRelief,
    ]

    static subscript(id: String) -> CourseDefinition? {
        all.first { $0.id == id }
    }

    /// Only the first program is free; the rest require premium.
    static let freeCourseIDs: Set<String> = ["screen-warrior"]

    var isFree: Bool { Self.freeCourseIDs.contains(id) }

    // MARK: 1 – Digital Eye Relief (30 days, beginner)

    static let screenWarrior = CourseDefinition(
        id: "screen-warrior",
        name: NSLocalizedString("Digital Eye Relief", comment: ""),
        subtitle: NSLocalizedString("30-Day Digital Eye Strain Program", comment: ""),
        description: NSLocalizedString("A daily routine designed for people who spend long hours at a screen. Combines focus-shift routines, relaxation, and the 20-20-20 idea.", comment: ""),
        durationDays: 30,
        difficulty: .beginner,
        icon: "desktopcomputer",
        color: .aveoTeal,
        badges: [NSLocalizedString("Office Workers", comment: "")],
        dailyPlan: buildScreenWarriorPlan()
    )

    // MARK: 2 – Vision After 40 (45 days, intermediate)

    static let visionBuilder = CourseDefinition(
        id: "vision-builder",
        name: NSLocalizedString("Vision After 40", comment: ""),
        subtitle: NSLocalizedString("45-Day Full Eye Fitness Program", comment: ""),
        description: NSLocalizedString("A 45-day routine for adults 40+. Combines movement, coordination, and focus-shift exercises into a structured daily plan.", comment: ""),
        durationDays: 45,
        difficulty: .intermediate,
        icon: "eye.trianglebadge.exclamationmark.fill",
        color: .aveoAccent,
        badges: [NSLocalizedString("Age 40+", comment: "")],
        dailyPlan: buildVisionBuilderPlan()
    )

    // MARK: 3 – Dry Eye Relief (30 days, beginner)

    static let dryEyeRelief = CourseDefinition(
        id: "dry-eye-relief",
        name: NSLocalizedString("Dry Eye Relief", comment: ""),
        subtitle: NSLocalizedString("30-Day Tear Film Restoration Program", comment: ""),
        description: NSLocalizedString("A 30-day daily routine for dry-eye self-care. Combines eyelid warmth, intentional blinking, and relaxation routines.", comment: ""),
        durationDays: 30,
        difficulty: .beginner,
        icon: "drop.fill",
        color: .aveoWarning,
        badges: [NSLocalizedString("Dry Eye Self-Care", comment: "")],
        dailyPlan: buildDryEyeReliefPlan()
    )
}

// MARK: – Plan Builders

private func buildScreenWarriorPlan() -> [CourseDefinition.DayPlan] {
    let w1: [[Int]] = [
        [0, 4, 13],
        [0, 2, 13],
        [0, 4, 2],
        [0, 4, 13, 2],
        [0, 2, 4],
        [0, 4, 13, 2],
    ]

    let w2: [[Int]] = [
        [0, 3, 4, 13],
        [0, 5, 2, 13],
        [3, 5, 4],
        [0, 3, 5, 13],
        [0, 5, 2, 4],
        [3, 5, 0, 13],
    ]

    let w3: [[Int]] = [
        [1, 0, 12, 13],
        [1, 3, 2, 12],
        [0, 1, 5, 12],
        [1, 3, 12, 13],
        [0, 1, 2, 12],
        [1, 5, 12, 13],
    ]

    let w4: [[Int]] = [
        [0, 1, 3, 12, 13],
        [0, 5, 4, 2],
        [1, 3, 12, 13],
        [0, 1, 5, 2, 13],
        [0, 3, 12, 4],
        [1, 5, 2, 13],
    ]

    let extra: [[Int]] = [
        [0, 1, 3, 5, 13],
        [0, 1, 3, 5, 12, 13],
    ]

    var plans: [CourseDefinition.DayPlan] = []
    var day = 1

    func addWeek(_ exercises: [[Int]], restAt: Int) {
        for exIndices in exercises {
            plans.append(.init(day: day, title: String(format: NSLocalizedString("Day %d", comment: ""), day), exerciseIndices: exIndices, restDay: false))
            day += 1
        }
        plans.append(.init(day: day, title: NSLocalizedString("Rest Day", comment: ""), exerciseIndices: [], restDay: true))
        day += 1
    }

    addWeek(w1, restAt: 7)
    addWeek(w2, restAt: 14)
    addWeek(w3, restAt: 21)
    addWeek(w4, restAt: 28)

    for (i, exIndices) in extra.enumerated() {
        let isLast = i == extra.count - 1
        plans.append(.init(day: day, title: isLast ? NSLocalizedString("Graduation Day", comment: "") : String(format: NSLocalizedString("Day %d", comment: ""), day), exerciseIndices: exIndices, restDay: false))
        day += 1
    }

    return plans
}

private func buildVisionBuilderPlan() -> [CourseDefinition.DayPlan] {
    let blocks: [[[Int]]] = [
        [[0, 1, 4], [0, 3, 2], [1, 5, 4], [0, 1, 3, 2], [0, 5, 4, 13], [1, 3, 2, 13]],
        [[0, 7, 4, 13], [1, 8, 2], [7, 3, 5, 13], [0, 8, 4, 2], [1, 7, 8, 13], [0, 3, 7, 2]],
        [[6, 0, 7, 4], [6, 1, 8, 13], [6, 3, 5, 2], [0, 6, 7, 12], [1, 6, 8, 4], [6, 3, 0, 13]],
        [[10, 6, 0, 7], [11, 6, 1, 8], [10, 6, 3, 2], [11, 0, 7, 12], [10, 1, 8, 13], [11, 6, 5, 2]],
        [[0, 1, 6, 10, 7], [3, 8, 11, 12, 4], [0, 6, 10, 5, 13], [1, 7, 11, 2, 12], [0, 3, 6, 10, 8], [1, 5, 11, 7, 13]],
        [[0, 1, 3, 6, 10, 7], [1, 5, 8, 11, 12], [0, 6, 7, 10, 13, 2]],
    ]

    var plans: [CourseDefinition.DayPlan] = []
    var day = 1

    for (weekIdx, week) in blocks.enumerated() {
        let isLastWeek = weekIdx == blocks.count - 1
        for (exIdx, exIndices) in week.enumerated() {
            let isGraduation = isLastWeek && exIdx == week.count - 1
            plans.append(.init(day: day, title: isGraduation ? NSLocalizedString("Graduation Day", comment: "") : String(format: NSLocalizedString("Day %d", comment: ""), day), exerciseIndices: exIndices, restDay: false))
            day += 1
        }
        if !isLastWeek {
            plans.append(.init(day: day, title: NSLocalizedString("Rest Day", comment: ""), exerciseIndices: [], restDay: true))
            day += 1
        }
    }

    return plans
}

private func buildDryEyeReliefPlan() -> [CourseDefinition.DayPlan] {
    let w1: [[Int]] = [
        [4, 14, 16],
        [9, 4, 2],
        [14, 16, 4],
        [9, 15, 2],
        [14, 16, 12],
        [9, 4, 15, 2],
    ]
    let w2: [[Int]] = [
        [14, 15, 16, 4],
        [9, 14, 12, 2],
        [15, 16, 4, 12],
        [9, 14, 16, 2],
        [15, 4, 12, 14],
        [9, 16, 15, 2],
    ]
    let w3: [[Int]] = [
        [14, 15, 16, 12],
        [9, 4, 14, 16],
        [15, 12, 2, 16],
        [9, 14, 15, 4],
        [16, 12, 14, 2],
        [9, 15, 16, 12],
    ]
    let w4: [[Int]] = [
        [14, 15, 16, 9, 4],
        [9, 14, 12, 16, 2],
        [15, 16, 4, 12, 14],
        [9, 14, 15, 16, 2],
        [9, 16, 15, 12, 4],
        [14, 15, 16, 9, 12],
    ]
    let extra: [[Int]] = [
        [9, 14, 15, 16, 4, 12],
        [9, 14, 15, 16, 12, 2],
    ]

    var plans: [CourseDefinition.DayPlan] = []
    var day = 1

    func addWeek(_ exercises: [[Int]]) {
        for exIndices in exercises {
            plans.append(.init(day: day, title: String(format: NSLocalizedString("Day %d", comment: ""), day), exerciseIndices: exIndices, restDay: false))
            day += 1
        }
        plans.append(.init(day: day, title: NSLocalizedString("Rest Day", comment: ""), exerciseIndices: [], restDay: true))
        day += 1
    }

    addWeek(w1)
    addWeek(w2)
    addWeek(w3)
    addWeek(w4)

    for (i, exIndices) in extra.enumerated() {
        let isLast = i == extra.count - 1
        plans.append(.init(day: day, title: isLast ? NSLocalizedString("Graduation Day", comment: "") : String(format: NSLocalizedString("Day %d", comment: ""), day), exerciseIndices: exIndices, restDay: false))
        day += 1
    }

    return plans
}
