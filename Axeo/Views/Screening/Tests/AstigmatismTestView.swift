import SwiftUI

/// Astigmatism screening — clock dial with radiating lines.
/// User reports if any lines appear darker/bolder.
struct AstigmatismTestView: View {
    let onComplete: (VisionTestRunnerView.TestOutcome) -> Void

    @State private var selectedLines: Set<Int> = []
    @State private var step = 0 // 0 = instructions, 1 = test, 2 = submit

    private let lineCount = 12

    var body: some View {
        VStack(spacing: 24) {
            if step == 0 {
                instructionsView
            } else {
                testView
            }
        }
    }

    private var instructionsView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(Color.aveoAccent)

            Text("Cover one eye. Look at the center of the dial. Do any lines appear darker, bolder, or more defined than others?")
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                HapticManager.medium()
                withAnimation { step = 1 }
            } label: {
                Text("I'm Ready")
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

    private var testView: some View {
        VStack(spacing: 20) {
            Text("Tap any lines that appear bolder or darker")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)
                .padding(.top, 16)

            Spacer()

            // Clock dial
            ZStack {
                Circle()
                    .strokeBorder(Color.aveoText3.opacity(0.15), lineWidth: 1)
                    .frame(width: 260, height: 260)

                ForEach(0..<lineCount, id: \.self) { i in
                    let angle = Double(i) / Double(lineCount) * .pi
                    let isSelected = selectedLines.contains(i)

                    Rectangle()
                        .fill(isSelected ? Color.aveoError : Color.aveoText)
                        .frame(width: isSelected ? 3 : 2, height: 110)
                        .rotationEffect(.radians(angle))
                        .onTapGesture {
                            HapticManager.selection()
                            if selectedLines.contains(i) {
                                selectedLines.remove(i)
                            } else {
                                selectedLines.insert(i)
                            }
                        }

                    // Degree label at ~75% radius
                    let degAngle = angle - .pi / 2
                    let degR: CGFloat = 82
                    Text("\(i * 15)°")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.aveoText3.opacity(0.6))
                        .position(
                            x: 130 + degR * cos(degAngle),
                            y: 130 + degR * sin(degAngle)
                        )

                    // Hour label
                    let labelAngle = angle - .pi / 2
                    let r: CGFloat = 145
                    Text("\(i + 1)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.aveoText3)
                        .position(
                            x: 130 + r * cos(labelAngle),
                            y: 130 + r * sin(labelAngle)
                        )
                }

                // Center dot
                Circle()
                    .fill(Color.aveoText)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 260, height: 260)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticManager.medium()
                    submitResult(allSame: true)
                } label: {
                    Text("All Lines Look the Same")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.aveoSuccess)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background {
                            Capsule().fill(Color.aveoSuccess.opacity(0.1))
                        }
                }

                Button {
                    HapticManager.medium()
                    submitResult(allSame: false)
                } label: {
                    Text(String(format: NSLocalizedString("Submit (%d selected)", comment: ""), selectedLines.count))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LinearGradient.aveoAccentGradient, in: Capsule())
                        .shadow(color: Color.aveoAccent.opacity(0.3), radius: 12, y: 4)
                }
                .disabled(selectedLines.isEmpty)
                .opacity(selectedLines.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func submitResult(allSame: Bool) {
        let passed = allSame
        onComplete(.init(
            passed: passed,
            summary: passed
                ? "All lines appeared equally clear — no signs of astigmatism detected."
                : "Some lines appeared darker, which may indicate astigmatism. We recommend a professional refraction test.",
            details: passed
                ? ["Result": "All lines equal"]
                : ["Darker Lines": selectedLines.sorted().map { "\($0 + 1)" }.joined(separator: ", ")]
        ))
    }
}
