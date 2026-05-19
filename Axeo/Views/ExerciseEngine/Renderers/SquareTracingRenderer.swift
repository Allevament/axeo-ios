import SwiftUI

/// Ex 7 – Square Tracing: Dot traces a square path, alternating CW/CCW.
struct SquareTracingRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Full square lap = 8 seconds
    private var lapFraction: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 8.0) / 8.0
    }

    private var lapNumber: Int {
        Int(progress * Double(duration) / 8.0)
    }

    private var isClockwise: Bool { lapNumber % 2 == 0 }

    private func dotPosition(in size: CGSize) -> CGPoint {
        let cx = size.width / 2
        let cy = size.height * 0.4
        let half: CGFloat = 100

        let corners: [CGPoint] = isClockwise
            ? [
                CGPoint(x: cx - half, y: cy - half), // TL
                CGPoint(x: cx + half, y: cy - half), // TR
                CGPoint(x: cx + half, y: cy + half), // BR
                CGPoint(x: cx - half, y: cy + half), // BL
              ]
            : [
                CGPoint(x: cx - half, y: cy - half), // TL
                CGPoint(x: cx - half, y: cy + half), // BL
                CGPoint(x: cx + half, y: cy + half), // BR
                CGPoint(x: cx + half, y: cy - half), // TR
              ]

        let segment = lapFraction * 4.0
        let idx = min(Int(segment), 3)
        let t = segment - Double(idx)
        let from = corners[idx]
        let to = corners[(idx + 1) % 4]

        return CGPoint(
            x: from.x + (to.x - from.x) * t,
            y: from.y + (to.y - from.y) * t
        )
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cx = size.width / 2
            let cy = size.height * 0.4
            let half: CGFloat = 100
            let dot = dotPosition(in: size)

            ZStack {
                // Square outline
                Rectangle()
                    .strokeBorder(Color.aveoAccent.opacity(0.12), lineWidth: 2)
                    .frame(width: half * 2, height: half * 2)
                    .position(x: cx, y: cy)

                // Corner dots
                ForEach(0..<4, id: \.self) { i in
                    let offsets: [(CGFloat, CGFloat)] = [(-1, -1), (1, -1), (1, 1), (-1, 1)]
                    Circle()
                        .fill(Color.aveoAccent.opacity(0.2))
                        .frame(width: 8, height: 8)
                        .position(
                            x: cx + offsets[i].0 * half,
                            y: cy + offsets[i].1 * half
                        )
                }

                // Direction indicator — prominent so the user sees current direction
                VStack(spacing: 4) {
                    Image(systemName: isClockwise ? "arrow.clockwise" : "arrow.counterclockwise")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.aveoAccent.opacity(0.7))
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.easeInOut(duration: 0.4), value: isClockwise)
                    Text(isClockwise ? NSLocalizedString("Clockwise", comment: "") : NSLocalizedString("Counter-clockwise", comment: ""))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.aveoText3)
                }
                .position(x: cx, y: cy)

                // Tracking dot
                Circle()
                    .fill(Color.aveoTeal)
                    .frame(width: 22, height: 22)
                    .shadow(color: .aveoTeal.opacity(0.5), radius: 10)
                    .position(dot)

                VStack {
                    Spacer()
                    Text(NSLocalizedString("Follow the dot smoothly", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
            .onChange(of: isClockwise) { _, _ in
                AudioManager.playPhaseChange()
                HapticManager.medium()
            }
        }
    }
}
