import SwiftUI

struct TestResultDetailView: View {
    let result: VisionTestResult

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    private var testType: VisionTestType? {
        VisionTestType(rawValue: result.testType)
    }

    private var color: Color {
        testType?.color ?? .aveoText3
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroSection
                    statusCard
                    if !result.details.isEmpty { detailsSection }
                    recommendationSection

                    // Post-test upgrade prompt for free users
                    if !appState.isPremium {
                        UpgradePromptView(
                            context: .postTest(testName: testType?.displayName ?? result.testType)
                        ) {
                            showPaywall = true
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(AmbientBackground())
            .navigationTitle(testType?.displayName ?? result.testType)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 64, height: 64)

                Circle()
                    .strokeBorder(
                        result.passed ? Color.aveoSuccess.opacity(0.3) : Color.aveoWarning.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: testType?.icon ?? "eye")
                    .font(.system(size: 24))
                    .foregroundStyle(color)
            }

            Text(testType?.displayName ?? result.testType)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)

            Text(formattedDate)
                .font(.system(size: 11))
                .foregroundStyle(Color.aveoText3)
        }
        .padding(.top, 8)
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        fmt.timeStyle = .short
        return fmt.string(from: result.timestamp)
    }

    // MARK: – Status

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: result.passed ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 22))
                .foregroundStyle(result.passed ? Color.aveoSuccess : Color.aveoWarning)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.passed
                     ? NSLocalizedString("Normal Result", comment: "")
                     : NSLocalizedString("Needs Review", comment: ""))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.aveoText)

                Text(result.summary)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.aveoText2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .fill((result.passed ? Color.aveoSuccess : Color.aveoWarning).opacity(0.06))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder((result.passed ? Color.aveoSuccess : Color.aveoWarning).opacity(0.15), lineWidth: 0.5)
        }
    }

    // MARK: – Details

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DETAILS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack(spacing: 10) {
                    Text(key.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.aveoText)

                    Spacer()

                    Text(value)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(color)
                }
                .padding(10)
                .glassCard(cornerRadius: 12, padding: 0)
            }
        }
    }

    // MARK: – Recommendation

    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECOMMENDATION")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            HStack(spacing: 10) {
                Image(systemName: result.passed ? "hand.thumbsup.fill" : "stethoscope")
                    .font(.system(size: 14))
                    .foregroundStyle(result.passed ? Color.aveoSuccess : Color.aveoWarning)
                    .frame(width: 28, height: 28)
                    .background {
                        RoundedRectangle(cornerRadius: 7)
                            .fill((result.passed ? Color.aveoSuccess : Color.aveoWarning).opacity(0.1))
                    }

                Text(result.passed
                     ? NSLocalizedString("Your result looks good. Continue regular screenings to monitor any changes.", comment: "")
                     : NSLocalizedString("We recommend scheduling an appointment with an eye care professional for a comprehensive examination.", comment: ""))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.aveoText2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .glassCard(cornerRadius: 14, padding: 0)
        }
    }
}

#Preview {
    TestResultDetailView(
        result: VisionTestResult(
            userId: UUID(),
            testType: "snellen",
            summary: "20/20 vision detected",
            passed: true,
            details: ["visual_acuity": "20/20", "smallest_line": "8"]
        )
    )
    .preferredColorScheme(.dark)
}
