import UIKit

enum HapticManager {
    // MARK: – Pre-instantiated generators (for immediate response)

    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private static let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    /// Call once at app launch to warm up haptic engines.
    static func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        rigidGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    static func light() {
        lightGenerator.impactOccurred()
    }

    static func medium() {
        mediumGenerator.impactOccurred()
    }

    static func heavy() {
        heavyGenerator.impactOccurred()
    }

    static func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    static func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    static func selection() {
        selectionGenerator.selectionChanged()
    }

    static func rigid() {
        rigidGenerator.impactOccurred()
    }

    static func soft() {
        softGenerator.impactOccurred()
    }
}
