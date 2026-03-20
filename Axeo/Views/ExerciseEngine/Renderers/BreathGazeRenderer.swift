import SwiftUI

/// Ex 12 – Breath + Gaze: Inhale 6s (gaze rises), exhale 7s (gaze lowers).
/// 15s per cycle.
struct BreathGazeRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    private var cycleFraction: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 15.0) / 15.0
    }

    // Inhale: 0→0.4 (6s), hold: 0.4→0.533 (2s), exhale: 0.533→1 (7s)
    private var phase: Phase {
        if cycleFraction < 0.4 { return .inhale }
        if cycleFraction < 0.533 { return .hold }
        return .exhale
    }

    private enum Phase {
        case inhale, hold, exhale
    }

    // Gaze Y position: 0=top, 1=bottom
    private var gazeY: CGFloat {
        switch phase {
        case .inhale:
            let t = cycleFraction / 0.4
            return CGFloat(1.0 - t) // bottom → top
        case .hold:
            return 0.0 // top
        case .exhale:
            let t = (cycleFraction - 0.533) / 0.467
            return CGFloat(t) // top → bottom
        }
    }

    // Breath ring scale
    private var breathScale: CGFloat {
        switch phase {
        case .inhale:
            let t = cycleFraction / 0.4
            return 0.5 + CGFloat(t) * 0.5
        case .hold:
            return 1.0
        case .exhale:
            let t = (cycleFraction - 0.533) / 0.467
            return 1.0 - CGFloat(t) * 0.5
        }
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let topY = geo.size.height * 0.18
            let bottomY = geo.size.height * 0.62
            let dotY = topY + (bottomY - topY) * gazeY

            ZStack {
                // Vertical guide
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.aveoTeal.opacity(0.15), .aveoAccent.opacity(0.15)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 2, height: bottomY - topY)
                    .position(x: cx, y: (topY + bottomY) / 2)

                // Top/bottom markers
                Circle()
                    .fill(Color.aveoTeal.opacity(0.2))
                    .frame(width: 10, height: 10)
                    .position(x: cx, y: topY)
                Circle()
                    .fill(Color.aveoAccent.opacity(0.2))
                    .frame(width: 10, height: 10)
                    .position(x: cx, y: bottomY)

                // Breath ring (centered)
                Circle()
                    .strokeBorder(Color.aveoTeal.opacity(0.2), lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(breathScale)
                    .position(x: cx, y: dotY)

                // Gaze dot
                Circle()
                    .fill(Color.aveoTeal)
                    .frame(width: 24, height: 24)
                    .shadow(color: .aveoTeal.opacity(0.5), radius: 12)
                    .position(x: cx, y: dotY)

                VStack(spacing: 8) {
                    Spacer()

                    Text(phaseLabel)
                        .font(.aveoHeadline)
                        .foregroundStyle(phaseColor)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: phase == .inhale)

                    Text(NSLocalizedString("Follow the dot with your gaze", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .inhale: NSLocalizedString("Breathe in ↑", comment: "")
        case .hold:   NSLocalizedString("Hold…", comment: "")
        case .exhale: NSLocalizedString("Breathe out ↓", comment: "")
        }
    }

    private var phaseColor: Color {
        switch phase {
        case .inhale: .aveoTeal
        case .hold:   .aveoGold
        case .exhale: .aveoAccent
        }
    }
}
