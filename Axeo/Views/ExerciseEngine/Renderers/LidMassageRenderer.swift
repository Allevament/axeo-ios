import SwiftUI

/// Ex 14 – Lid Massage: Visual guide showing massage direction.
struct LidMassageRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Alternate upper (0→0.5) and lower (0.5→1) lid per 6s cycle
    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 6.0) / 6.0
    }

    private var isUpperLid: Bool { cyclePhase < 0.5 }

    // Sweep progress within half-cycle: 0→1
    private var sweep: CGFloat {
        let half = isUpperLid ? cyclePhase / 0.5 : (cyclePhase - 0.5) / 0.5
        return CGFloat(half)
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.38

            ZStack {
                // Eye outline (large)
                Canvas { context, size in
                    let eyeW: CGFloat = 130
                    let eyeH: CGFloat = 50

                    // Upper arc
                    var upper = Path()
                    upper.move(to: CGPoint(x: cx - eyeW, y: cy))
                    upper.addQuadCurve(
                        to: CGPoint(x: cx + eyeW, y: cy),
                        control: CGPoint(x: cx, y: cy - eyeH)
                    )
                    context.stroke(upper, with: .color(.aveoAccent.opacity(0.2)), lineWidth: 2)

                    // Lower arc
                    var lower = Path()
                    lower.move(to: CGPoint(x: cx - eyeW, y: cy))
                    lower.addQuadCurve(
                        to: CGPoint(x: cx + eyeW, y: cy),
                        control: CGPoint(x: cx, y: cy + eyeH)
                    )
                    context.stroke(lower, with: .color(.aveoAccent.opacity(0.2)), lineWidth: 2)
                }

                // Sweep indicator (finger position)
                let sweepX = cx + 120 - sweep * 240 // temple-to-nose = right-to-left
                let offsetY: CGFloat = isUpperLid ? -35 : 35

                // Arrow path
                Image(systemName: "arrow.left")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.aveoGold.opacity(0.4))
                    .position(x: cx, y: cy + offsetY - 20)

                // Finger indicator
                Circle()
                    .fill(Color.aveoGold)
                    .frame(width: 18, height: 18)
                    .shadow(color: .aveoGold.opacity(0.4), radius: 8)
                    .position(x: sweepX, y: cy + offsetY)

                // Label
                Text(isUpperLid ? NSLocalizedString("Upper lid", comment: "") : NSLocalizedString("Lower lid", comment: ""))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.aveoGold.opacity(0.5))
                    .position(x: cx, y: cy + offsetY + 30)

                VStack(spacing: 8) {
                    Spacer()
                    Text(NSLocalizedString("Massage gently, temple to nose", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)

                    Text(NSLocalizedString("Light pressure only", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
