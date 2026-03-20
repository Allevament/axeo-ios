import SwiftUI

/// Ex 13 – 20-20-20 Rule: Simple 20-second countdown looking at something far.
struct Rule2020Renderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    private var remaining: Int {
        max(0, Int(Double(duration) * (1.0 - progress)))
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.35

            ZStack {
                // Outer countdown ring
                Circle()
                    .strokeBorder(Color.aveoAccent.opacity(0.1), lineWidth: 6)
                    .frame(width: 200, height: 200)
                    .position(x: cx, y: cy)

                Circle()
                    .trim(from: 0, to: 1.0 - progress)
                    .stroke(
                        LinearGradient(
                            colors: [.aveoTeal, .aveoAccent],
                            startPoint: .top, endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .position(x: cx, y: cy)

                // "20" numbers stacked
                VStack(spacing: 2) {
                    Text("\(remaining)")
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.aveoText)
                        .contentTransition(.numericText())

                    Text(NSLocalizedString("seconds", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .position(x: cx, y: cy)

                // Distant landscape hint
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.aveoTeal.opacity(0.15))
                    .position(x: cx, y: cy + 140)

                VStack(spacing: 8) {
                    Spacer()
                    Text(NSLocalizedString("Look at something 20 feet away", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)

                    Text(NSLocalizedString("Let your eye muscles fully relax", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
