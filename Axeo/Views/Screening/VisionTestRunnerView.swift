import SwiftUI
import SwiftData

/// Full-screen test runner. Manages intro → test → result flow.
struct VisionTestRunnerView: View {
    let testType: VisionTestType

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var phase: Phase = .intro
    @State private var testResult: TestOutcome?

    enum Phase {
        case intro, testing, result
    }

    struct TestOutcome {
        let passed: Bool
        let summary: String
        let details: [String: String]
    }

    var body: some View {
        ZStack {
            Color.aveoBg.ignoresSafeArea()

            switch phase {
            case .intro:
                introView
            case .testing:
                testView
            case .result:
                resultView
            }
        }
        .statusBarHidden(phase == .testing)
    }

    // MARK: – Intro

    private var introView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(testType.color.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: testType.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(testType.color)
            }

            Text(testType.displayName)
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)

            Text(testType.subtitle)
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            AlertBanner(message: testType.disclaimer, variant: .warning)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticManager.medium()
                    withAnimation { phase = .testing }
                } label: {
                    Label("Start Test", systemImage: "play.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.aveoBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [testType.color, testType.color.opacity(0.7)],
                                startPoint: .leading, endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .shadow(color: testType.color.opacity(0.3), radius: 12, y: 4)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: – Test (dispatches to specific test)

    private var testView: some View {
        Group {
            switch testType {
            case .snellen:
                SnellenTestView { outcome in completeTest(outcome) }
            case .astigmatism:
                AstigmatismTestView { outcome in completeTest(outcome) }
            case .colorVision:
                ColorVisionTestView { outcome in completeTest(outcome) }
            case .contrastSensitivity:
                ContrastTestView { outcome in completeTest(outcome) }
            case .amslerGrid:
                AmslerGridTestView { outcome in completeTest(outcome) }
            case .dryEye:
                DryEyeTestView { outcome in completeTest(outcome) }
            }
        }
    }

    // MARK: – Result

    @ViewBuilder
    private var resultView: some View {
        if let result = testResult {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: result.passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(result.passed ? Color.aveoSuccess : Color.aveoWarning)

                Text(result.passed ? "Results Look Normal" : "We Recommend a Professional Check")
                    .font(.aveoLargeTitle)
                    .foregroundStyle(Color.aveoText)
                    .multilineTextAlignment(.center)

                Text(result.summary)
                    .font(.aveoBody)
                    .foregroundStyle(Color.aveoText2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Detail items
                if !result.details.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(result.details.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.aveoText3)
                                Spacer()
                                Text(value)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.aveoText)
                            }
                        }
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 16, padding: 0)
                    .padding(.horizontal, 24)
                }

                AlertBanner(message: NSLocalizedString("This screening is not a substitute for a professional eye exam.", comment: ""), variant: .info)
                    .padding(.horizontal, 24)

                Spacer()

                Button {
                    HapticManager.light()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient.aveoAccentGradient,
                            in: Capsule()
                        )
                        .shadow(color: Color.aveoAccent.opacity(0.3), radius: 12, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: – Helpers

    private func completeTest(_ outcome: TestOutcome) {
        testResult = outcome
        HapticManager.success()
        AudioManager.playGong()

        // Save result
        if let userId = appState.currentUser?.id {
            let result = VisionTestResult(
                userId: userId,
                testType: testType.rawValue,
                summary: outcome.summary,
                passed: outcome.passed,
                details: outcome.details
            )
            modelContext.insert(result)
            try? modelContext.save()
        }

        withAnimation(.spring(duration: 0.4)) {
            phase = .result
        }
    }
}
