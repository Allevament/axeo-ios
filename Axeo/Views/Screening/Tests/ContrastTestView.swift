import SwiftUI

/// Contrast Sensitivity — letters fade progressively.
struct ContrastTestView: View {
    let onComplete: (VisionTestRunnerView.TestOutcome) -> Void

    @State private var currentLevel = 0
    @State private var userAnswer = ""
    @State private var correctCount = 0

    private let levels: [(opacity: Double, letter: String, label: String)] = [
        (0.80, "E", "High contrast"),
        (0.60, "H", "Medium-high"),
        (0.40, "N", "Medium"),
        (0.25, "R", "Medium-low"),
        (0.15, "C", "Low"),
        (0.08, "D", "Very low"),
        (0.04, "O", "Minimal"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text(String(format: NSLocalizedString("Plate %d of %d", comment: ""), currentLevel + 1, levels.count))
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
                Spacer()
                Text("Contrast: \(Int(levels[min(currentLevel, levels.count - 1)].opacity * 100))%")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.aveoGold)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            // Letter at current contrast
            if currentLevel < levels.count {
                Text(levels[currentLevel].letter)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.aveoText.opacity(levels[currentLevel].opacity))
                    .id(currentLevel)
            }

            Text(levels[min(currentLevel, levels.count - 1)].label)
                .font(.system(size: 12))
                .foregroundStyle(Color.aveoText3)

            Spacer()

            VStack(spacing: 12) {
                Text("What letter do you see?")
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)

                HStack(spacing: 12) {
                    TextField("", text: $userAnswer)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.aveoText)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .frame(width: 80)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.aveoGlass)
                                }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 12).strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
                        }
                        .aveoShadowSm()

                    Button {
                        HapticManager.light()
                        submit(cantSee: true)
                    } label: {
                        Text("Can't See")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.aveoText3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background { Capsule().fill(Color.aveoText3.opacity(0.1)) }
                    }

                    Button {
                        HapticManager.medium()
                        submit(cantSee: false)
                    } label: {
                        Text("Next")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(LinearGradient.aveoTealGradient, in: Capsule())
                            .shadow(color: Color.aveoTeal.opacity(0.3), radius: 12, y: 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func submit(cantSee: Bool) {
        if !cantSee && userAnswer.uppercased().trimmingCharacters(in: .whitespaces) == levels[currentLevel].letter {
            correctCount += 1
        }
        userAnswer = ""

        let next = currentLevel + 1
        if cantSee || next >= levels.count {
            let lastLevel = cantSee ? max(0, currentLevel - 1) : levels.count - 1
            let passed = lastLevel >= 3
            onComplete(.init(
                passed: passed,
                summary: passed
                    ? "You read \(correctCount) of \(levels.count) contrast levels — contrast sensitivity appears normal."
                    : "You had difficulty below \(levels[lastLevel].label) contrast. Consider a professional contrast sensitivity test.",
                details: [
                    "Levels Read": "\(correctCount) of \(levels.count)",
                    "Lowest Contrast": levels[lastLevel].label
                ]
            ))
        } else {
            withAnimation(.spring(duration: 0.3)) {
                currentLevel = next
            }
        }
    }
}
