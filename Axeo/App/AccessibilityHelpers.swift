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
    /// Scales a fixed size relative to the user's Dynamic Type preference.
    static func aveoScaled(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        .system(size: size, weight: weight, design: design)
    }
}
