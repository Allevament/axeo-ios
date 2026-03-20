import SwiftUI

/// Visual Acuity test — progressively smaller letters.
struct SnellenTestView: View {
    let onComplete: (VisionTestRunnerView.TestOutcome) -> Void

    @State private var currentRow = 0
    @State private var userInput = ""
    @State private var correctCount = 0
    @State private var totalAttempted = 0
    @State private var isSubmitting = false

    // Snellen rows: size decreases, each row has 5 letters
    private let rows: [(size: CGFloat, letters: String, acuity: String)] = [
        (72, "E",       "20/200"),
        (56, "FP",      "20/100"),
        (44, "TOZ",     "20/70"),
        (36, "LPED",    "20/50"),
        (28, "PECFD",   "20/40"),
        (22, "EDFCZP",  "20/30"),
        (18, "FELOPZD", "20/25"),
        (14, "DEFPOTEC","20/20"),
        (11, "FDPLTCEO","20/15"),
    ]

    private var currentLetters: String {
        guard currentRow < rows.count else { return "" }
        return rows[currentRow].letters
    }

    var body: some View {
        VStack(spacing: 24) {
            // Progress
            HStack {
                Text(String(format: NSLocalizedString("Row %d of %d", comment: ""), currentRow + 1, rows.count))
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
                Spacer()
                Text(rows[min(currentRow, rows.count - 1)].acuity)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.aveoTeal)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Text("Hold at arm's length (20 inches)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.aveoText3.opacity(0.7))
                .padding(.horizontal, 24)

            Spacer()

            // Letters display
            if currentRow < rows.count {
                Text(currentLetters)
                    .font(.system(size: rows[currentRow].size, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.aveoText)
                    .tracking(rows[currentRow].size * 0.3)
                    .id(currentRow) // force re-render
            }

            Spacer()

            // Input area
            VStack(spacing: 12) {
                Text("Type the letters you see")
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)

                TextField("", text: $userInput)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.aveoText)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.aveoGlass)
                            }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
                    }
                    .aveoShadowSm()
                    .padding(.horizontal, 40)

                HStack(spacing: 16) {
                    Button {
                        HapticManager.light()
                        submitAnswer(canSee: false)
                    } label: {
                        Text("Can't See")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.aveoText3)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background {
                                Capsule().fill(Color.aveoText3.opacity(0.1))
                            }
                    }

                    Button {
                        HapticManager.medium()
                        submitAnswer(canSee: true)
                    } label: {
                        Text("Submit")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient.aveoTealGradient,
                                in: Capsule()
                            )
                            .shadow(color: Color.aveoTeal.opacity(0.3), radius: 12, y: 4)
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func submitAnswer(canSee: Bool) {
        guard !isSubmitting else { return }
        isSubmitting = true
        totalAttempted += 1

        if canSee {
            let expected = currentLetters.uppercased()
            let given = userInput.uppercased().trimmingCharacters(in: .whitespaces)
            let matches = zip(expected, given).filter { $0 == $1 }.count
            if matches >= max(1, expected.count / 2) {
                correctCount += 1
            }
        }

        userInput = ""
        let nextRow = currentRow + 1

        if !canSee || nextRow >= rows.count {
            let lastReadable = canSee ? min(currentRow, rows.count - 1) : max(0, currentRow - 1)
            let acuity = rows[lastReadable].acuity

            // Three-tier status
            let status: String
            let passed: Bool
            if lastReadable >= 5 { // 20/30 or better
                status = NSLocalizedString("Normal", comment: "")
                passed = true
            } else if lastReadable >= 3 { // 20/50 to 20/30
                status = NSLocalizedString("Mild reduction", comment: "")
                passed = true
            } else { // Below 20/50
                status = NSLocalizedString("Below normal", comment: "")
                passed = false
            }

            onComplete(.init(
                passed: passed,
                summary: "Your estimated acuity is \(acuity) (\(status)). \(passed ? "This is within acceptable range." : "Consider a professional eye exam.")",
                details: [
                    "Estimated Acuity": acuity,
                    "Status": status,
                    "Rows Completed": "\(lastReadable + 1) of \(rows.count)",
                    "Correct Rows": "\(correctCount)"
                ]
            ))
        } else {
            withAnimation(.spring(duration: 0.3)) {
                currentRow = nextRow
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isSubmitting = false
            }
        }
    }
}
