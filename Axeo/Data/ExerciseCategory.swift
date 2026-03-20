import SwiftUI

// MARK: – Category Type

enum ExerciseCategoryType: String, CaseIterable, Identifiable {
    case accommodation
    case eyeMovement
    case relaxation
    case binocular
    case breathing
    case dryEyeRelief

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .accommodation:  NSLocalizedString("Accommodation", comment: "")
        case .eyeMovement:    NSLocalizedString("Eye Movement", comment: "")
        case .relaxation:     NSLocalizedString("Relaxation", comment: "")
        case .binocular:      NSLocalizedString("Binocular", comment: "")
        case .breathing:      NSLocalizedString("Breathing", comment: "")
        case .dryEyeRelief:   NSLocalizedString("Dry Eye Relief", comment: "")
        }
    }

    var subtitle: String {
        switch self {
        case .accommodation:  NSLocalizedString("Ciliary muscle training — myopia prevention & accommodation relief", comment: "")
        case .eyeMovement:    NSLocalizedString("Extraocular muscle training — all 6 directions of gaze", comment: "")
        case .relaxation:     NSLocalizedString("Muscle and visual tension relief — 20-20-20 rule", comment: "")
        case .binocular:      NSLocalizedString("Teamwork of both eyes — stereovision development", comment: "")
        case .breathing:      NSLocalizedString("Breathing synchronized with eye movement — WHO protocol", comment: "")
        case .dryEyeRelief:   NSLocalizedString("Tear film stabilization & eyelid health — TFOS DEWS II", comment: "")
        }
    }

    var sfSymbol: String {
        switch self {
        case .accommodation:  "scope"
        case .eyeMovement:    "arrow.up.and.down.and.arrow.left.and.right"
        case .relaxation:     "leaf.fill"
        case .binocular:      "eyes"
        case .breathing:      "wind"
        case .dryEyeRelief:   "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .accommodation:  .aveoAccent
        case .eyeMovement:    .aveoData
        case .relaxation:     .aveoSuccess
        case .binocular:      .aveoRetinal
        case .breathing:      .aveoGold
        case .dryEyeRelief:   .aveoWarning
        }
    }

    /// Exercise indices belonging to this category.
    var exerciseIndices: [Int] {
        switch self {
        case .accommodation:  [0, 5]
        case .eyeMovement:    [1, 3, 7, 8]
        case .relaxation:     [2, 4, 9]
        case .binocular:      [6, 10, 11]
        case .breathing:      [12, 13]
        case .dryEyeRelief:   [14, 15, 16]
        }
    }

    /// The exercises in this category.
    var exercises: [ExerciseDefinition] {
        exerciseIndices.compactMap { ExerciseDefinition[$0] }
    }

    /// Total duration in seconds for all exercises in this category.
    var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.duration }
    }
}
