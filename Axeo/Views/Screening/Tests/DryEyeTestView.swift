import SwiftUI

/// OSDI-based Dry Eye questionnaire (simplified 6 questions).
struct DryEyeTestView: View {
    let onComplete: (VisionTestRunnerView.TestOutcome) -> Void

    @State private var currentQ = 0
    @State private var scores: [Int] = []

    private let questions: [(q: String, context: String)] = [
        ("How often do your eyes feel sensitive to light?",
         "Indoors or outdoors"),
        ("How often do your eyes feel gritty or sandy?",
         "As if there's something in your eye"),
        ("How often do you experience painful or sore eyes?",
         "Aching, burning, or stinging"),
        ("How often is your vision blurry?",
         "Fluctuating or intermittent blur"),
        ("Do your eyes bother you when reading or using screens?",
         "After 30+ minutes of near work"),
        ("Do your eyes feel uncomfortable in windy or dry environments?",
         "Air conditioning, heating, or windy days"),
    ]

    private let options = [
        "Never",
        "Sometimes",
        "Half the Time",
        "Most of the Time",
        "Always",
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Progress
            HStack {
                Text(String(format: NSLocalizedString("Plate %d of %d", comment: ""), currentQ + 1, questions.count))
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.aveoText3.opacity(0.12))
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.aveoWarning)
                        .frame(width: geo.size.width * CGFloat(currentQ) / CGFloat(questions.count), height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)

            Spacer()

            // Question
            VStack(spacing: 8) {
                Text(questions[currentQ].q)
                    .font(.aveoTitle)
                    .foregroundStyle(Color.aveoText)
                    .multilineTextAlignment(.center)
                    .id(currentQ)

                Text(questions[currentQ].context)
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Options
            VStack(spacing: 10) {
                ForEach(Array(options.enumerated()), id: \.offset) { idx, option in
                    Button {
                        HapticManager.selection()
                        answer(score: idx)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.aveoText)
                            Spacer()
                            Circle()
                                .strokeBorder(severityColor(idx), lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .fill(severityColor(idx))
                                        .frame(width: 8, height: 8)
                                }
                        }
                        .padding(14)
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
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func severityColor(_ index: Int) -> Color {
        switch index {
        case 0: .aveoSuccess
        case 1: .aveoTeal
        case 2: .aveoGold
        case 3: .aveoWarning
        default: .aveoError
        }
    }

    private func answer(score: Int) {
        scores.append(score)
        let next = currentQ + 1

        if next >= questions.count {
            let total = scores.reduce(0, +)
            let maxScore = questions.count * 4
            let percentage = Double(total) / Double(maxScore) * 100
            let severity: String
            let passed: Bool

            switch percentage {
            case 0..<15:
                severity = "Normal"
                passed = true
            case 15..<33:
                severity = "Mild dry eye"
                passed = true
            case 33..<60:
                severity = "Moderate dry eye"
                passed = false
            default:
                severity = "Severe dry eye symptoms"
                passed = false
            }

            onComplete(.init(
                passed: passed,
                summary: "\(severity). Your OSDI score is \(Int(percentage))%. \(passed ? "Your symptoms are within normal range." : "We recommend consulting an eye care professional about dry eye management.")",
                details: [
                    "OSDI Score": "\(Int(percentage))%",
                    "Raw Score": "\(total) / \(maxScore)",
                    "Severity": severity
                ]
            ))
        } else {
            withAnimation(.spring(duration: 0.3)) {
                currentQ = next
            }
        }
    }
}
