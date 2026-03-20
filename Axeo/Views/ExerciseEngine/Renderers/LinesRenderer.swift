import SwiftUI

/// Ex 8 – Vertical & Horizontal: Dot moves up-down then left-right.
struct LinesRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // First half = vertical (up-down), second half = horizontal (left-right)
    private var isVerticalPhase: Bool { progress < 0.5 }

    // Within each phase, oscillate
    private var phaseProgress: Double {
        isVerticalPhase ? progress * 2.0 : (progress - 0.5) * 2.0
    }

    // ~2.5s per direction change
    private var oscillation: Double {
        let elapsed = phaseProgress * Double(duration) / 2.0
        return sin(elapsed / 2.5 * .pi)
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.4
            let range: CGFloat = 120

            let dotX: CGFloat = isVerticalPhase ? cx : cx + range * CGFloat(oscillation)
            let dotY: CGFloat = isVerticalPhase ? cy + range * CGFloat(oscillation) : cy

            ZStack {
                // Guide lines
                if isVerticalPhase {
                    Rectangle()
                        .fill(Color.aveoAccent.opacity(0.08))
                        .frame(width: 2, height: range * 2)
                        .position(x: cx, y: cy)

                    // End markers
                    ForEach([-1.0, 1.0], id: \.self) { dir in
                        Circle()
                            .fill(Color.aveoAccent.opacity(0.15))
                            .frame(width: 10, height: 10)
                            .position(x: cx, y: cy + range * CGFloat(dir))
                    }
                } else {
                    Rectangle()
                        .fill(Color.aveoAccent.opacity(0.08))
                        .frame(width: range * 2, height: 2)
                        .position(x: cx, y: cy)

                    ForEach([-1.0, 1.0], id: \.self) { dir in
                        Circle()
                            .fill(Color.aveoAccent.opacity(0.15))
                            .frame(width: 10, height: 10)
                            .position(x: cx + range * CGFloat(dir), y: cy)
                    }
                }

                // Crosshair
                Group {
                    Rectangle()
                        .fill(Color.aveoTeal.opacity(0.15))
                        .frame(width: 1, height: 20)
                    Rectangle()
                        .fill(Color.aveoTeal.opacity(0.15))
                        .frame(width: 20, height: 1)
                }
                .position(x: dotX, y: dotY)

                // Tracking dot
                Circle()
                    .fill(Color.aveoTeal)
                    .frame(width: 22, height: 22)
                    .shadow(color: .aveoTeal.opacity(0.5), radius: 10)
                    .position(x: dotX, y: dotY)

                VStack(spacing: 8) {
                    Spacer()
                    Text(isVerticalPhase ? NSLocalizedString("Up and down", comment: "") : NSLocalizedString("Left and right", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)

                    Text(NSLocalizedString("Keep your head still", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
