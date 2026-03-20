import SwiftUI

/// Ex 9 – Warm Compress: 3-minute guided timer with warmth visual.
struct WarmCompressRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Breathing: 5s in, 5s out → 10s cycle
    private var breathPhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 10.0) / 10.0
    }

    private var isInhale: Bool { breathPhase < 0.5 }

    private var glowScale: CGFloat {
        let t = isInhale ? breathPhase * 2 : (1.0 - (breathPhase - 0.5) * 2)
        return 0.7 + CGFloat(t) * 0.3
    }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.38)

            ZStack {
                // Warmth rings
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(
                            Color.aveoWarning.opacity(0.02 + Double(i) * 0.015)
                        )
                        .frame(
                            width: CGFloat(50 + i * 45),
                            height: CGFloat(50 + i * 45)
                        )
                        .scaleEffect(glowScale)
                        .animation(.easeInOut(duration: 5.0), value: isInhale)
                        .position(center)
                }

                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.aveoWarning, .aveoError.opacity(0.7)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .scaleEffect(glowScale * 0.9)
                    .animation(.easeInOut(duration: 5.0), value: isInhale)
                    .position(center)

                VStack(spacing: 8) {
                    Spacer()

                    // Time remaining
                    let remaining = Int(Double(duration) * (1.0 - progress))
                    let mins = remaining / 60
                    let secs = remaining % 60
                    Text(String(format: "%d:%02d", mins, secs))
                        .font(.aveoMono)
                        .foregroundStyle(Color.aveoWarning)

                    Text(isInhale ? NSLocalizedString("Breathe in…", comment: "") : NSLocalizedString("Breathe out…", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)

                    Text(NSLocalizedString("Keep the warm cloth over closed eyes", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
