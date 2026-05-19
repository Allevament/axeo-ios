import SwiftUI

/// Ex 1 – Figure Eight: A dot traces an ∞ Lissajous path.
struct FigureEightRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Direction reverses at halfway through the exercise.
    private var isForward: Bool { progress < 0.5 }

    // Full loop every ~7 seconds. After midpoint, replay in reverse so the
    // dot smoothly continues from where the first half ended.
    private var angle: Double {
        if isForward {
            return progress * Double(duration) / 7.0 * 2.0 * .pi
        } else {
            // Mirror time around the midpoint so trajectory reverses.
            let mid = 0.5
            let mirrored = mid - (progress - mid)
            return mirrored * Double(duration) / 7.0 * 2.0 * .pi
        }
    }

    private func dotPosition(in size: CGSize) -> CGPoint {
        let cx = size.width / 2
        let cy = size.height * 0.42
        let rx = size.width * 0.35
        let ry = size.height * 0.15
        // Lissajous: x = sin(t), y = sin(2t)
        let x = cx + rx * sin(angle)
        let y = cy + ry * sin(2 * angle)
        return CGPoint(x: x, y: y)
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let dot = dotPosition(in: size)

            ZStack {
                // Trail path
                figureEightPath(in: size)
                    .stroke(Color.aveoAccent.opacity(0.12), lineWidth: 2)

                // Progress trail
                figureEightPath(in: size)
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.aveoAccent, .aveoTeal],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )

                // Tracking dot
                Circle()
                    .fill(Color.aveoTeal)
                    .frame(width: 24, height: 24)
                    .shadow(color: .aveoTeal.opacity(0.5), radius: 12)
                    .position(dot)

                // Direction badge (top-center) — flips at the midpoint
                VStack(spacing: 4) {
                    Image(systemName: isForward ? "arrow.forward.circle" : "arrow.backward.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.aveoAccent.opacity(0.7))
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.easeInOut(duration: 0.4), value: isForward)
                    Text(isForward ? NSLocalizedString("Forward", comment: "") : NSLocalizedString("Reverse", comment: ""))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.aveoText3)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 12)

                // Instruction
                VStack {
                    Spacer()
                    Text(NSLocalizedString("Follow the dot with your eyes", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
            .onChange(of: isForward) { _, _ in
                AudioManager.playPhaseChange()
                HapticManager.medium()
            }
        }
    }

    private func figureEightPath(in size: CGSize) -> Path {
        Path { path in
            let cx = size.width / 2
            let cy = size.height * 0.42
            let rx = size.width * 0.35
            let ry = size.height * 0.15
            let steps = 200
            for i in 0...steps {
                let t = Double(i) / Double(steps) * 2.0 * .pi
                let x = cx + rx * sin(t)
                let y = cy + ry * sin(2 * t)
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
}
