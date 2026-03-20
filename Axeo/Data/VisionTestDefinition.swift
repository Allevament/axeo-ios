import SwiftUI

// MARK: – Vision Test Type

enum VisionTestType: String, CaseIterable, Identifiable {
    case snellen
    case astigmatism
    case colorVision
    case contrastSensitivity
    case amslerGrid
    case dryEye

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .snellen:              NSLocalizedString("Visual Acuity", comment: "")
        case .astigmatism:          NSLocalizedString("Astigmatism Check", comment: "")
        case .colorVision:          NSLocalizedString("Color Vision", comment: "")
        case .contrastSensitivity:  NSLocalizedString("Contrast Sensitivity", comment: "")
        case .amslerGrid:           NSLocalizedString("Amsler Grid", comment: "")
        case .dryEye:               NSLocalizedString("Dry Eye Assessment", comment: "")
        }
    }

    var subtitle: String {
        switch self {
        case .snellen:              NSLocalizedString("Snellen chart — read progressively smaller letters", comment: "")
        case .astigmatism:          NSLocalizedString("Fan/clock dial — check for directional blur", comment: "")
        case .colorVision:          NSLocalizedString("Ishihara-style plates — detect color deficiency", comment: "")
        case .contrastSensitivity:  NSLocalizedString("Fading letters — check low-contrast vision", comment: "")
        case .amslerGrid:           NSLocalizedString("Grid distortion — screen for macular issues", comment: "")
        case .dryEye:               NSLocalizedString("OSDI questionnaire — rate your dry eye symptoms", comment: "")
        }
    }

    var icon: String {
        switch self {
        case .snellen:              "eye.fill"
        case .astigmatism:          "circle.dashed"
        case .colorVision:          "paintpalette.fill"
        case .contrastSensitivity:  "circle.lefthalf.filled"
        case .amslerGrid:           "grid"
        case .dryEye:               "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .snellen:              .aveoAccent
        case .astigmatism:          .aveoRetinal
        case .colorVision:          .aveoSuccess
        case .contrastSensitivity:  .aveoGold
        case .amslerGrid:           .aveoData
        case .dryEye:               .aveoWarning
        }
    }

    var durationLabel: String {
        switch self {
        case .snellen:              NSLocalizedString("~2 min", comment: "")
        case .astigmatism:          NSLocalizedString("~1 min", comment: "")
        case .colorVision:          NSLocalizedString("~2 min", comment: "")
        case .contrastSensitivity:  NSLocalizedString("~1 min", comment: "")
        case .amslerGrid:           NSLocalizedString("~1 min", comment: "")
        case .dryEye:               NSLocalizedString("~3 min", comment: "")
        }
    }

    var disclaimer: String {
        NSLocalizedString("This is a screening tool, not a medical diagnosis. Consult an eye care professional for a comprehensive exam.", comment: "")
    }

    /// Free tests available without premium.
    static let freeTests: Set<VisionTestType> = [.snellen, .colorVision]

    var isFree: Bool { Self.freeTests.contains(self) }
}
