import SwiftUI

/// Ex 15 – Lid Gym: Squeeze shut (2s) → open wide (2s) cycle.
struct LidGymRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // 4s cycle: 2s shut + 2s open
    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 4.0) / 4.0
    }

    private var isSqueeze: Bool { cyclePhase < 0.5 }

    private var eyeOpenness: CGFloat {
        if isSqueeze {
            let t = cyclePhase / 0.5 // 0→1 during squeeze
            return max(0, 1.0 - CGFloat(t) * 1.3) // close past zero for "squeeze"
        } else {
            let t = (cyclePhase - 0.5) / 0.5 // 0→1 during open
            return min(1.3, CGFloat(t) * 1.3) // open wider than normal
        }
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.38

            ZStack {
                // Eye shape via Canvas
                Canvas { context, size in
                    let eyeW: CGFloat = 120
                    let maxH: CGFloat = 55
                    let h = maxH * max(eyeOpenness, 0)

                    // Upper lid
                    var upper = Path()
                    upper.move(to: CGPoint(x: cx - eyeW, y: cy))
                    upper.addQuadCurve(
                        to: CGPoint(x: cx + eyeW, y: cy),
                        control: CGPoint(x: cx, y: cy - h)
                    )

                    var lower = Path()
                    lower.move(to: CGPoint(x: cx - eyeW, y: cy))
                    lower.addQuadCurve(
                        to: CGPoint(x: cx + eyeW, y: cy),
                        control: CGPoint(x: cx, y: cy + h)
                    )

                    // Fill
                    var eyeShape = upper
                    eyeShape.addPath(lower)
                    let fillColor = isSqueeze
                        ? Color.aveoWarning.opacity(0.08)
                        : Color.aveoTeal.opacity(0.08)
                    context.fill(eyeShape, with: .color(fillColor))

                    let strokeColor = isSqueeze
                        ? Color.aveoWarning.opacity(0.5)
                        : Color.aveoTeal.opacity(0.5)
                    context.stroke(upper, with: .color(strokeColor), lineWidth: 2.5)
                    context.stroke(lower, with: .color(strokeColor), lineWidth: 2.5)

                    // Iris + pupil only when open enough
                    if eyeOpenness > 0.3 {
                        let irisR = min(h * 0.6, 20)
                        let irisRect = CGRect(
                            x: cx - irisR, y: cy - irisR,
                            width: irisR * 2, height: irisR * 2
                        )
                        context.fill(Circle().path(in: irisRect), with: .color(.aveoTeal))

                        let pupilR = irisR * 0.4
                        let pupilRect = CGRect(
                            x: cx - pupilR, y: cy - pupilR,
                            width: pupilR * 2, height: pupilR * 2
                        )
                        context.fill(Circle().path(in: pupilRect), with: .color(Color(hex: 0x0A0D1A)))
                    }
                }

                // Squeeze/open indicators
                if isSqueeze {
                    // Arrows pointing inward (squeeze)
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.aveoWarning.opacity(0.4))
                        .position(x: cx, y: cy - 70)
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.aveoWarning.opacity(0.4))
                        .position(x: cx, y: cy + 70)
                } else {
                    // Arrows pointing outward (open wide)
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.aveoTeal.opacity(0.4))
                        .position(x: cx, y: cy - 70)
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.aveoTeal.opacity(0.4))
                        .position(x: cx, y: cy + 70)
                }

                VStack(spacing: 8) {
                    Spacer()
                    Text(isSqueeze ? NSLocalizedString("Squeeze shut!", comment: "") : NSLocalizedString("Open wide!", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(isSqueeze ? Color.aveoWarning : Color.aveoTeal)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: isSqueeze)

                    Text(NSLocalizedString("Keep the rhythm steady", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
