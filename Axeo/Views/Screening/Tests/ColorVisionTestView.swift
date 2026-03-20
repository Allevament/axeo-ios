import SwiftUI

/// Ishihara-style color vision test with 6 plates.
struct ColorVisionTestView: View {
    let onComplete: (VisionTestRunnerView.TestOutcome) -> Void

    @State private var currentPlate = 0
    @State private var correctCount = 0
    @State private var userAnswer = ""
    @State private var plateOrder = Array(0..<6).shuffled()

    // Simplified Ishihara-style plates: background color, dot color, number
    private let plates: [(bg: Color, dots: Color, number: String, description: String)] = [
        (.init(hex: 0xCD853F), .init(hex: 0xCC4444), "12", "Red-green plate 1"),
        (.init(hex: 0x7B9E3F), .init(hex: 0xCC6633), "8",  "Red-green plate 2"),
        (.init(hex: 0xCC8844), .init(hex: 0x44AA44), "6",  "Red-green plate 3"),
        (.init(hex: 0x6699CC), .init(hex: 0x9944CC), "29", "Blue-purple plate"),
        (.init(hex: 0xCC6644), .init(hex: 0x44AA66), "45", "Red-green plate 4"),
        (.init(hex: 0x88AA44), .init(hex: 0xCC5544), "74", "Red-green plate 5"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(String(format: NSLocalizedString("Plate %d of %d", comment: ""), currentPlate + 1, plates.count))
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            // Plate display (shuffled order)
            let plate = plates[plateOrder[currentPlate]]
            ZStack {
                Circle()
                    .fill(plate.bg)
                    .frame(width: 220, height: 220)

                // Dot pattern (simulated with overlapping circles)
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let r: CGFloat = 100

                    // Background dots
                    for _ in 0..<120 {
                        let angle = Double.random(in: 0...2 * .pi)
                        let dist = CGFloat.random(in: 0...r)
                        let x = center.x + dist * cos(angle)
                        let y = center.y + dist * sin(angle)
                        let dotR = CGFloat.random(in: 4...10)
                        let rect = CGRect(x: x - dotR, y: y - dotR, width: dotR * 2, height: dotR * 2)
                        context.fill(Circle().path(in: rect), with: .color(plate.bg.opacity(Double.random(in: 0.6...1.0))))
                    }
                }
                .frame(width: 220, height: 220)

                // Number in dot color
                Text(plate.number)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(plate.dots)
            }

            Text("What number do you see?")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)

            Spacer()

            // Input
            HStack(spacing: 12) {
                TextField("Number", text: $userAnswer)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.aveoText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
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
                    .frame(width: 140)

                Button {
                    HapticManager.light()
                    submitPlate(cantSee: true)
                } label: {
                    Text("I don't see a number")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.aveoText3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background {
                            Capsule().fill(Color.aveoText3.opacity(0.1))
                        }
                }

                Button {
                    HapticManager.medium()
                    submitPlate(cantSee: false)
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.aveoTeal)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func submitPlate(cantSee: Bool) {
        if !cantSee && userAnswer.trimmingCharacters(in: .whitespaces) == plates[plateOrder[currentPlate]].number {
            correctCount += 1
        }
        userAnswer = ""

        let next = currentPlate + 1
        if next >= plates.count {
            let passed = correctCount >= 5
            onComplete(.init(
                passed: passed,
                summary: passed
                    ? "You correctly identified \(correctCount)/\(plates.count) plates — color vision appears normal."
                    : "You identified \(correctCount)/\(plates.count) plates. This may suggest a color vision deficiency. We recommend a professional Ishihara test.",
                details: [
                    "Correct Plates": "\(correctCount) of \(plates.count)",
                    "Result": passed ? "Normal color vision" : "Possible deficiency"
                ]
            ))
        } else {
            withAnimation(.spring(duration: 0.3)) {
                currentPlate = next
            }
        }
    }
}
