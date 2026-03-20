import SwiftUI

/// Ex 4 – Blinking: Visual guide showing open/close cycle every 5 seconds.
struct BlinkingRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // 5-second cycle: 2s open → 1s closing → 1s closed → 1s opening
    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 5.0)
    }

    private var eyeOpenness: CGFloat {
        if cyclePhase < 2.0 { return 1.0 }       // open
        if cyclePhase < 3.0 { return CGFloat(1.0 - (cyclePhase - 2.0)) } // closing
        if cyclePhase < 4.0 { return 0.0 }       // closed
        return CGFloat(cyclePhase - 4.0)          // opening
    }

    private var instruction: String {
        if cyclePhase < 2.0 { return NSLocalizedString("Eyes open — relax", comment: "") }
        if cyclePhase < 3.5 { return NSLocalizedString("Slowly close…", comment: "") }
        return NSLocalizedString("Slowly open…", comment: "")
    }

    var body: some View {
        GeometryReader { geo in
            let centerY = geo.size.height * 0.4

            ZStack {
                // Eye shape
                Canvas { context, size in
                    let cx = size.width / 2
                    let eyeWidth: CGFloat = 120
                    let maxHeight: CGFloat = 50
                    let h = maxHeight * eyeOpenness

                    // Upper lid
                    var upper = Path()
                    upper.move(to: CGPoint(x: cx - eyeWidth, y: centerY))
                    upper.addQuadCurve(
                        to: CGPoint(x: cx + eyeWidth, y: centerY),
                        control: CGPoint(x: cx, y: centerY - h)
                    )

                    // Lower lid
                    var lower = Path()
                    lower.move(to: CGPoint(x: cx - eyeWidth, y: centerY))
                    lower.addQuadCurve(
                        to: CGPoint(x: cx + eyeWidth, y: centerY),
                        control: CGPoint(x: cx, y: centerY + h)
                    )

                    // Fill eye shape
                    var eyeShape = upper
                    eyeShape.addPath(lower)
                    context.fill(eyeShape, with: .color(.aveoAccent.opacity(0.08)))
                    context.stroke(upper, with: .color(.aveoAccent.opacity(0.5)), lineWidth: 2)
                    context.stroke(lower, with: .color(.aveoAccent.opacity(0.5)), lineWidth: 2)

                    // Iris
                    if eyeOpenness > 0.15 {
                        let irisR = min(h * 0.7, 22)
                        let irisRect = CGRect(
                            x: cx - irisR, y: centerY - irisR,
                            width: irisR * 2, height: irisR * 2
                        )
                        context.fill(Circle().path(in: irisRect), with: .color(.aveoTeal))

                        // Pupil
                        let pupilR = irisR * 0.45
                        let pupilRect = CGRect(
                            x: cx - pupilR, y: centerY - pupilR,
                            width: pupilR * 2, height: pupilR * 2
                        )
                        context.fill(Circle().path(in: pupilRect), with: .color(Color(hex: 0x0A0D1A)))

                        // Highlight
                        let hlR = pupilR * 0.35
                        let hlRect = CGRect(
                            x: cx - irisR * 0.3 - hlR,
                            y: centerY - irisR * 0.3 - hlR,
                            width: hlR * 2, height: hlR * 2
                        )
                        context.fill(Circle().path(in: hlRect), with: .color(.white.opacity(0.6)))
                    }
                }

                VStack(spacing: 8) {
                    Spacer()
                    Text(instruction)
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                        .animation(.easeInOut(duration: 0.3), value: instruction)

                    Text(NSLocalizedString("Slow, deliberate blinks", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
