import SwiftUI

/// Ex 2 – Palming: Guided breathing circles + darkness.
/// No visual tracking — just calming animation.
struct PalmingRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    @State private var didStart = false
    @State private var didMidpoint = false

    // Breathing: 4s in, 4s out → 8s cycle
    private var breathPhase: Double {
        let elapsed = progress * Double(duration)
        let inCycle = elapsed.truncatingRemainder(dividingBy: 8.0)
        return inCycle / 8.0
    }

    private var isInhale: Bool { breathPhase < 0.5 }

    private var breathScale: CGFloat {
        let t = isInhale ? breathPhase * 2 : (1.0 - (breathPhase - 0.5) * 2)
        return 0.6 + CGFloat(t) * 0.4
    }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.4)

            ZStack {
                // Warm glow rings
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(
                            Color.aveoGold.opacity(0.03 + Double(i) * 0.02)
                        )
                        .frame(
                            width: CGFloat(60 + i * 50),
                            height: CGFloat(60 + i * 50)
                        )
                        .scaleEffect(breathScale)
                        .aveoAnimation(.easeInOut(duration: 4.0), value: isInhale)
                        .position(center)
                }

                // Center palm icon
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.aveoGold.opacity(0.4))
                    .scaleEffect(breathScale * 0.8)
                    .aveoAnimation(.easeInOut(duration: 4.0), value: isInhale)
                    .position(center)

                VStack(spacing: 8) {
                    Spacer()

                    Text(isInhale ? NSLocalizedString("Breathe in…", comment: "") : NSLocalizedString("Breathe out…", comment: ""))
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoGold)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.5), value: isInhale)

                    Text(NSLocalizedString("Cup warm palms over closed eyes", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
            .onAppear {
                // Start cue + ambient loop — tells user it's time to close eyes
                if !didStart {
                    AudioManager.playPhaseChange()
                    AmbientAudioPlayer.startLoop(.gentlePiano)
                    didStart = true
                }
            }
            .onDisappear {
                AmbientAudioPlayer.stopLoop()
            }
            .onChange(of: progress) { _, p in
                // Mid-point cue
                if !didMidpoint && p >= 0.5 {
                    AudioManager.playMidpoint()
                    didMidpoint = true
                }
            }
        }
    }
}
