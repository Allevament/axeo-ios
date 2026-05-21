import SwiftUI

// MARK: – Reduce Motion Support

extension Animation {
    /// Returns the animation or `.default` if Reduce Motion is enabled.
    static func aveo(_ animation: Animation, duration: Double = 0.3) -> Animation {
        if UIAccessibility.isReduceMotionEnabled {
            return .easeOut(duration: 0.15)
        }
        return animation
    }
}

extension View {
    /// Applies animation only when Reduce Motion is off.
    @ViewBuilder
    func aveoAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            self
        } else {
            self.animation(animation, value: value)
        }
    }

    /// Accessibility label + hint shorthand.
    func axLabel(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
}

// MARK: – Dynamic Type Scaling

extension Font {
    /// Scales a fixed point size by the user's Dynamic Type setting using
    /// UIKit's `UIFontMetrics`. Previous implementation was a no-op and
    /// silently broke Dynamic Type app-wide.
    static func aveoScaled(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        let scaled = UIFontMetrics.default.scaledValue(for: size)
        return .system(size: scaled, weight: weight, design: design)
    }
}
