import SwiftUI

/// Ex 10 – Stereogram: Two circles — user relaxes eyes to fuse them into one.
struct StereogramRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Circles slowly pulse to hint at fusion
    private var pulseScale: CGFloat {
        let t = sin(progress * Double(duration) / 3.0 * .pi)
        return 1.0 + CGFloat(t) * 0.08
    }

    // Gentle drift toward center over time
    private var driftFraction: CGFloat {
        CGFloat(min(progress * 2.0, 1.0)) * 0.15
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.4
            let baseSep: CGFloat = 65
            let sep = baseSep * (1.0 - driftFraction)
            let r: CGFloat = 50

            ZStack {
                // Guide line
                Rectangle()
                    .fill(Color.aveoAccent.opacity(0.06))
                    .frame(width: sep * 2 + r * 2, height: 1)
                    .position(x: cx, y: cy)

                // Left circle
                stereogramCircle(color: .aveoTeal)
                    .scaleEffect(pulseScale)
                    .position(x: cx - sep, y: cy)

                // Right circle
                stereogramCircle(color: .aveoAccent)
                    .scaleEffect(pulseScale)
                    .position(x: cx + sep, y: cy)

                // Fusion hint (appears late)
                if progress > 0.4 {
                    Circle()
                        .strokeBorder(Color.aveoGold.opacity(0.15), lineWidth: 2)
                        .frame(width: r * 2, height: r * 2)
                        .position(x: cx, y: cy)
                        .transition(.opacity)
                }

                VStack(spacing: 8) {
                    Spacer()
                    Text(NSLocalizedString("Relax your eyes — let the circles merge", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)

                    Text(NSLocalizedString("Don't force it — let focus go soft", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func stereogramCircle(color: Color) -> some View {
        ZStack {
            Circle()
                .strokeBorder(color, lineWidth: 3)
                .frame(width: 100, height: 100)
            Circle()
                .fill(color.opacity(0.08))
                .frame(width: 100, height: 100)
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
        }
    }
}
