import SwiftUI

/// Ex 0 – Focus Shift: A dot pulses between near/far states.
/// User alternates focus between the screen dot and a distant object.
struct FocusShiftRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // One full near-far cycle = 6 seconds (3s near + 3s far)
    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        let inCycle = elapsed.truncatingRemainder(dividingBy: 6.0)
        return inCycle / 6.0 // 0→0.5 = near, 0.5→1 = far
    }

    private var isNearPhase: Bool { cyclePhase < 0.5 }

    private var dotScale: CGFloat {
        isNearPhase ? 1.0 : 0.35
    }

    private var instructionText: String {
        isNearPhase ? NSLocalizedString("Focus on the dot", comment: "") : NSLocalizedString("Look at a distant object", comment: "")
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height * 0.42)

            ZStack {
                // Concentric rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .strokeBorder(
                            Color.aveoTeal.opacity(0.08 + Double(i) * 0.04),
                            lineWidth: 1
                        )
                        .frame(width: CGFloat(80 + i * 60), height: CGFloat(80 + i * 60))
                        .position(center)
                }

                // Focus dot
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.aveoTeal, .aveoTeal.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(dotScale)
                    .animation(.easeInOut(duration: 0.8), value: isNearPhase)
                    .position(center)

                // Glow
                Circle()
                    .fill(Color.aveoTeal.opacity(isNearPhase ? 0.25 : 0.05))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                    .scaleEffect(dotScale)
                    .animation(.easeInOut(duration: 0.8), value: isNearPhase)
                    .position(center)

                // Instruction
                VStack(spacing: 8) {
                    Spacer()
                    Text(instructionText)
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: isNearPhase)

                    Text(isNearPhase ? NSLocalizedString("Hold for 3 seconds", comment: "") : NSLocalizedString("Relax your focus", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
