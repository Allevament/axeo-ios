import SwiftUI

/// Ex 16 – Tear Film: Slow complete blink + distant gaze cycle.
/// 5s total: 1s closing, 1s hold, 1s opening, then 2s looking far.
struct TearFilmRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    private var cyclePhase: Double {
        let elapsed = progress * Double(duration)
        return elapsed.truncatingRemainder(dividingBy: 6.0) / 6.0
    }

    private enum Phase: Equatable {
        case closing, holdClosed, opening, distantGaze
    }

    private var phase: Phase {
        if cyclePhase < 0.167 { return .closing }      // 1s
        if cyclePhase < 0.333 { return .holdClosed }    // 1s
        if cyclePhase < 0.5   { return .opening }       // 1s
        return .distantGaze                              // 3s
    }

    /// Coarse "look at screen vs. away" — used for audio cue trigger.
    private var isDistantPhase: Bool { phase == .distantGaze }

    /// Remove "Restoring tear film stability" wellness-jargon footer.
    private var subtitleText: String {
        NSLocalizedString("Slow complete blink + distant gaze cycle", comment: "")
    }

    private var eyeOpenness: CGFloat {
        switch phase {
        case .closing:
            let t = cyclePhase / 0.167
            return 1.0 - CGFloat(t)
        case .holdClosed:
            return 0
        case .opening:
            let t = (cyclePhase - 0.333) / 0.167
            return CGFloat(t)
        case .distantGaze:
            return 1.0
        }
    }

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let cy = geo.size.height * 0.38

            ZStack {
                // Tear drops falling animation
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "drop.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.aveoTeal.opacity(phase == .holdClosed ? 0.4 : 0.1))
                        .position(
                            x: cx - 20 + CGFloat(i) * 20,
                            y: cy + 60 + (phase == .holdClosed ? 10 : 0)
                        )
                        .animation(.easeInOut(duration: 0.5), value: phase == .holdClosed)
                }

                // Eye Canvas
                Canvas { context, size in
                    let eyeW: CGFloat = 120
                    let maxH: CGFloat = 50
                    let h = maxH * max(eyeOpenness, 0)

                    var upper = Path()
                    upper.move(to: CGPoint(x: cx - eyeW, y: cy))
                    upper.addQuadCurve(
                        to: CGPoint(x: cx + eyeW, y: cy),
                        control: CGPoint(x: cx, y: cy - h)
                    )

                    var lower = Path()
                    lower.move(to: CGPoint(x: cx - eyeW, y: cy))
                    lower.addQuadCurve(
                        to: CGPoint(x: cx + eyeW, y: cy),
                        control: CGPoint(x: cx, y: cy + h)
                    )

                    var eyeShape = upper
                    eyeShape.addPath(lower)
                    context.fill(eyeShape, with: .color(.aveoTeal.opacity(0.06)))
                    context.stroke(upper, with: .color(.aveoTeal.opacity(0.4)), lineWidth: 2)
                    context.stroke(lower, with: .color(.aveoTeal.opacity(0.4)), lineWidth: 2)

                    if eyeOpenness > 0.2 {
                        let irisR = min(h * 0.6, 20)
                        let irisRect = CGRect(
                            x: cx - irisR, y: cy - irisR,
                            width: irisR * 2, height: irisR * 2
                        )
                        context.fill(Circle().path(in: irisRect), with: .color(.aveoTeal))

                        let pupilR = irisR * 0.4
                        let pupilRect = CGRect(
                            x: cx - pupilR, y: cy - pupilR,
                            width: pupilR * 2, height: pupilR * 2
                        )
                        context.fill(Circle().path(in: pupilRect), with: .color(Color(hex: 0x0A0D1A)))
                    }
                }

                // Distant gaze indicator
                if phase == .distantGaze {
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.aveoTeal.opacity(0.2))
                        .position(x: cx, y: cy - 80)
                        .transition(.opacity)
                }

                VStack(spacing: 8) {
                    Spacer()
                    Text(phaseLabel)
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: cyclePhase < 0.5)

                    Text(subtitleText)
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
            .onAppear { AmbientAudioPlayer.startLoop(.gentlePiano) }
            .onDisappear { AmbientAudioPlayer.stopLoop() }
            .onChange(of: isDistantPhase) { _, _ in
                AudioManager.playPhaseChange()
                HapticManager.light()
            }
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .closing:     NSLocalizedString("Close slowly…", comment: "")
        case .holdClosed:  NSLocalizedString("Hold closed — tears spreading", comment: "")
        case .opening:     NSLocalizedString("Open gently…", comment: "")
        case .distantGaze: NSLocalizedString("Look at something distant", comment: "")
        }
    }
}
