import Foundation

// MARK: – Quick Session Builder

enum QuickSession {

    /// Default quick session: 5 balanced exercises.
    static let defaultIndices: [Int] = [0, 1, 2, 3, 12]

    /// Builds a randomized session based on user's goal and diagnosis.
    /// Returns 3-5 exercise indices, balanced across categories.
    /// Each call shuffles within categories to produce fresh recommendations.
    static func build(goal: User.Goal, diagnosis: User.Diagnosis?, isPremium: Bool = false, recentIndices: Set<Int> = []) -> [Int] {
        let priorities = categoryPriority(goal: goal, diagnosis: diagnosis).shuffled()
        var picked: [Int] = []

        // Pick one random exercise per priority category (up to 5)
        for category in priorities {
            guard picked.count < 5 else { break }
            let candidates = category.exerciseIndices.filter {
                !recentIndices.contains($0) && !picked.contains($0) && (isPremium || $0 < ExerciseDefinition.premiumThreshold)
            }
            if let choice = candidates.randomElement() {
                picked.append(choice)
            }
        }

        // Fill remaining slots randomly from available exercises
        if picked.count < 3 {
            let remaining = ExerciseDefinition.all.filter {
                !picked.contains($0.index) && (isPremium || $0.index < ExerciseDefinition.premiumThreshold)
            }.shuffled()
            for ex in remaining where picked.count < 3 {
                picked.append(ex.index)
            }
        }

        return picked
    }

    /// Category priority order based on user's condition.
    private static func categoryPriority(goal: User.Goal, diagnosis: User.Diagnosis?) -> [ExerciseCategoryType] {
        switch diagnosis {
        case .myopia:
            return [.accommodation, .eyeMovement, .relaxation, .breathing, .binocular, .dryEyeRelief]
        case .hyperopia, .presbyopia:
            return [.accommodation, .relaxation, .eyeMovement, .breathing, .binocular, .dryEyeRelief]
        case .astigmatism:
            return [.eyeMovement, .accommodation, .relaxation, .breathing, .binocular, .dryEyeRelief]
        case .dryEye:
            return [.dryEyeRelief, .relaxation, .breathing, .accommodation, .eyeMovement, .binocular]
        default:
            switch goal {
            case .prevention:
                return [.accommodation, .eyeMovement, .relaxation, .breathing, .binocular, .dryEyeRelief]
            case .correction:
                return [.eyeMovement, .accommodation, .binocular, .relaxation, .breathing, .dryEyeRelief]
            case .relaxation:
                return [.relaxation, .breathing, .dryEyeRelief, .accommodation, .eyeMovement, .binocular]
            }
        }
    }
}
