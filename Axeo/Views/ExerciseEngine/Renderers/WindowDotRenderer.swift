import SwiftUI

/// Ex 5 – Window Dot: Alternate focus between a near dot and distant horizon.
/// 10 seconds near, 10 seconds far → 20s cycle.
struct WindowDotRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 20.0)
    }

    private var isNearPhase: Bool { cyclePhase < 10.0 }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.4

            ZStack {
                // Window frame
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.aveoText3.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 260)
                    .position(x: cx, y: cy)

                // Window cross
                Rectangle()
                    .fill(Color.aveoText3.opacity(0.1))
                    .frame(width: 2, height: 260)
                    .position(x: cx, y: cy)
                Rectangle()
                    .fill(Color.aveoText3.opacity(0.1))
                    .frame(width: 200, height: 2)
                    .position(x: cx, y: cy)

                // Far scenery (mountain silhouette)
                if !isNearPhase {
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.aveoTeal.opacity(0.3))
                        .position(x: cx, y: cy - 20)
                        .transition(.opacity)
                }

                // Near dot (on the "glass")
                Circle()
                    .fill(
                        isNearPhase
                            ? Color.aveoAccent
                            : Color.aveoAccent.opacity(0.2)
                    )
                    .frame(width: isNearPhase ? 20 : 10, height: isNearPhase ? 20 : 10)
                    .shadow(color: isNearPhase ? .aveoAccent.opacity(0.5) : .clear, radius: 8)
                    .position(x: cx, y: cy)
                    .animation(.easeInOut(duration: 0.6), value: isNearPhase)

                // Instruction
                VStack(spacing: 8) {
                    Spacer()
                    Text(isNearPhase ? NSLocalizedString("Focus on the dot", comment: "") : NSLocalizedString("Focus on something far away", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: isNearPhase)

                    // Countdown within phase
                    let remaining = isNearPhase
                        ? Int(10.0 - cyclePhase)
                        : Int(20.0 - cyclePhase)
                    Text("\(remaining)" + NSLocalizedString("s remaining", comment: ""))
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.aveoTeal)
                }
                .padding(.bottom, 40)
            }
            .onChange(of: isNearPhase) { _, _ in
                AudioManager.playPhaseChange()
                HapticManager.light()
            }
        }
    }
}
