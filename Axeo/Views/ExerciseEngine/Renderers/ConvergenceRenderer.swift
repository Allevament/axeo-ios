import SwiftUI

/// Ex 6 – Convergence: A dot moves toward/away from center simulating near approach.
struct ConvergenceRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // 10s approach, 10s retreat → 20s cycle
    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 20.0) / 20.0
    }

    /// 0→0.5 = approaching (dot grows), 0.5→1 = retreating (dot shrinks)
    private var approachFraction: CGFloat {
        let t = cyclePhase < 0.5 ? cyclePhase * 2 : (1.0 - (cyclePhase - 0.5) * 2)
        return CGFloat(t)
    }

    private var isApproaching: Bool { cyclePhase < 0.5 }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.4

            ZStack {
                // Depth rings
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .strokeBorder(Color.aveoAccent.opacity(0.04 + Double(i) * 0.02), lineWidth: 1)
                        .frame(
                            width: CGFloat(40 + i * 40),
                            height: CGFloat(40 + i * 40)
                        )
                        .position(x: cx, y: cy)
                }

                // Main convergence dot — scales from small (far) to large (near)
                let dotSize: CGFloat = 14 + approachFraction * 40
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.aveoTeal, .aveoTeal.opacity(0.2)],
                            center: .center,
                            startRadius: 0,
                            endRadius: dotSize
                        )
                    )
                    .frame(width: dotSize, height: dotSize)
                    .shadow(color: .aveoTeal.opacity(Double(approachFraction) * 0.5), radius: 16)
                    .position(x: cx, y: cy)

                // Secondary dots (convergence target — two dots that merge)
                let separation = (1.0 - approachFraction) * 50
                Circle()
                    .fill(Color.aveoAccent.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .position(x: cx - separation, y: cy)
                Circle()
                    .fill(Color.aveoAccent.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .position(x: cx + separation, y: cy)

                VStack(spacing: 8) {
                    Spacer()
                    Text(isApproaching ? NSLocalizedString("Keep the dot single and clear", comment: "") : NSLocalizedString("Slowly moving away…", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: isApproaching)

                    Text(NSLocalizedString("If it doubles, relax your eyes", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
