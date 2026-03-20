import SwiftUI
import SwiftData

struct AllScreeningsView: View {
    @Query(sort: \VisionTestResult.timestamp, order: .reverse) private var results: [VisionTestResult]
    @State private var selectedResult: VisionTestResult?

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                summaryStrip

                if results.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(results) { result in
                            let testType = VisionTestType(rawValue: result.testType)
                            let color = testType?.color ?? .aveoText3

                            Button {
                                HapticManager.selection()
                                selectedResult = result
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: testType?.icon ?? "eye")
                                        .font(.system(size: 13))
                                        .foregroundStyle(color)
                                        .frame(width: 30, height: 30)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(color.opacity(0.1))
                                        }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(testType?.displayName ?? result.testType)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(Color.aveoText)
                                        Text(result.summary)
                                            .font(.system(size: 9))
                                            .foregroundStyle(Color.aveoText3)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Image(systemName: result.passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(result.passed ? Color.aveoSuccess : Color.aveoWarning)

                                        Text(result.timestamp, format: .dateTime.month(.abbreviated).day().hour().minute())
                                            .font(.system(size: 8))
                                            .foregroundStyle(Color.aveoText3)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Color.aveoText3)
                                }
                                .padding(10)
                                .glassCard(cornerRadius: 12, padding: 0)
                            }
                            .buttonStyle(.pressScale)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AmbientBackground())
        .navigationTitle("All Screenings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedResult) { result in
            TestResultDetailView(result: result)
        }
    }

    private var summaryStrip: some View {
        let passed = results.filter(\.passed).count
        let failed = results.count - passed

        return HStack(spacing: 0) {
            miniStat("\(results.count)", label: NSLocalizedString("Total", comment: ""), color: .aveoData)
            miniStat("\(passed)", label: NSLocalizedString("Normal", comment: ""), color: .aveoSuccess)
            miniStat("\(failed)", label: NSLocalizedString("Review", comment: ""), color: .aveoWarning)
        }
        .glassCard(cornerRadius: 14, padding: 0)
    }

    private func miniStat(_ value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.system(size: 28))
                .foregroundStyle(Color.aveoText3.opacity(0.4))
            Text("No screenings yet")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationStack {
        AllScreeningsView()
    }
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
