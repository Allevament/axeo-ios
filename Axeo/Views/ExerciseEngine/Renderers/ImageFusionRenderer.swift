import SwiftUI

/// Ex 11 – Image Fusion: Two circles that move apart and together.
/// User maintains single vision (fusion) while separation changes.
struct ImageFusionRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Oscillate separation: ~6s cycle
    private var separation: CGFloat {
        let t = sin(progress * Double(duration) / 6.0 * 2.0 * .pi)
        return CGFloat(30 + t * 45) // 30→75→30
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.4

            ZStack {
                // Horizontal guide
                Rectangle()
                    .fill(Color.aveoAccent.opacity(0.06))
                    .frame(width: 250, height: 1)
                    .position(x: cx, y: cy)

                // Left circle
                fusionCircle(color: .aveoTeal)
                    .position(x: cx - separation, y: cy)

                // Right circle
                fusionCircle(color: .aveoAccent2)
                    .position(x: cx + separation, y: cy)

                // Center fusion target
                Circle()
                    .strokeBorder(
                        Color.aveoGold.opacity(separation < 40 ? 0.4 : 0.08),
                        lineWidth: 2
                    )
                    .frame(width: 80, height: 80)
                    .position(x: cx, y: cy)

                VStack(spacing: 8) {
                    Spacer()

                    if separation < 40 {
                        Text(NSLocalizedString("Good — maintain fusion!", comment: ""))
                            .font(.aveoHeadline)
                            .foregroundStyle(Color.aveoSuccess)
                    } else {
                        Text(NSLocalizedString("Keep both circles as one", comment: ""))
                            .font(.aveoHeadline)
                            .foregroundStyle(Color.aveoText)
                    }

                    Text(NSLocalizedString("Relax if you see double", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func fusionCircle(color: Color) -> some View {
        ZStack {
            Circle()
                .strokeBorder(color, lineWidth: 2.5)
                .frame(width: 70, height: 70)
            Circle()
                .fill(color.opacity(0.06))
                .frame(width: 70, height: 70)
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        }
    }
}
