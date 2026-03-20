import SwiftUI

/// Amsler Grid — user reports distortion/missing areas in a grid.
struct AmslerGridTestView: View {
    let onComplete: (VisionTestRunnerView.TestOutcome) -> Void

    @State private var step = 0 // 0 = instructions, 1 = right eye, 2 = left eye
    @State private var rightEyeNormal = true
    @State private var leftEyeNormal = true

    var body: some View {
        VStack(spacing: 20) {
            if step == 0 {
                instructionsView
            } else {
                gridTestView
            }
        }
    }

    private var instructionsView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "grid")
                .font(.system(size: 48))
                .foregroundStyle(Color.aveoError)

            Text("Cover your LEFT eye. Focus on the center dot. Are all lines straight? Are there any missing, wavy, or distorted areas?")
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            AlertBanner(message: "Hold your phone at normal reading distance (~14 inches).", variant: .info)
                .padding(.horizontal, 24)

            Spacer()

            Button {
                HapticManager.medium()
                withAnimation { step = 1 }
            } label: {
                Text("Start — Right Eye First")
                    .font(.aveoHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient.aveoAccentGradient, in: Capsule())
                    .shadow(color: Color.aveoAccent.opacity(0.3), radius: 12, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var gridTestView: some View {
        let eyeLabel = step == 1 ? "Right Eye" : "Left Eye"
        let coverLabel = step == 1 ? "Cover your LEFT eye" : "Cover your RIGHT eye"

        return VStack(spacing: 16) {
            Text(eyeLabel)
                .font(.aveoTitle)
                .foregroundStyle(Color.aveoText)
            Text(coverLabel)
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)

            Spacer()

            // Amsler Grid
            ZStack {
                // Grid lines
                Canvas { context, size in
                    let step: CGFloat = size.width / 20
                    let lineColor = Color.aveoText.opacity(0.3)

                    for i in 0...20 {
                        let x = CGFloat(i) * step
                        var vLine = Path()
                        vLine.move(to: CGPoint(x: x, y: 0))
                        vLine.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(vLine, with: .color(lineColor), lineWidth: 0.5)

                        let y = CGFloat(i) * step
                        var hLine = Path()
                        hLine.move(to: CGPoint(x: 0, y: y))
                        hLine.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(hLine, with: .color(lineColor), lineWidth: 0.5)
                    }
                }
                .frame(width: 280, height: 280)
                .background(Color.aveoBg2)

                // Center dot
                Circle()
                    .fill(Color.aveoError)
                    .frame(width: 8, height: 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))

            Text("Focus only on the center dot")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticManager.medium()
                    recordResult(normal: true)
                } label: {
                    Label("All Lines Straight — No Issues", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.aveoSuccess)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background { Capsule().fill(Color.aveoSuccess.opacity(0.1)) }
                }

                Button {
                    HapticManager.medium()
                    recordResult(normal: false)
                } label: {
                    Label("I See Distortion or Missing Areas", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.aveoWarning)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background { Capsule().fill(Color.aveoWarning.opacity(0.1)) }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func recordResult(normal: Bool) {
        if step == 1 {
            rightEyeNormal = normal
            withAnimation { step = 2 }
        } else {
            leftEyeNormal = normal
            let passed = rightEyeNormal && leftEyeNormal
            onComplete(.init(
                passed: passed,
                summary: passed
                    ? "Both eyes reported straight grid lines — no macular concerns detected."
                    : "Distortion was reported. This does not necessarily indicate a problem, but we recommend seeing an ophthalmologist.",
                details: [
                    "Right Eye": rightEyeNormal ? "Normal" : "Distortion reported",
                    "Left Eye": leftEyeNormal ? "Normal" : "Distortion reported"
                ]
            ))
        }
    }
}
