import SwiftUI
import SwiftData

struct ScreeningListView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \VisionTestResult.timestamp, order: .reverse) private var results: [VisionTestResult]
    @State private var selectedTest: VisionTestType?
    @State private var disclaimerExpanded = true
    @State private var selectedResult: VisionTestResult?
    @State private var showAllHistory = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                disclaimerBanner
                testGrid
                recentResults
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AmbientBackground())
        .navigationTitle("Vision Screening")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedTest) { testType in
            VisionTestRunnerView(testType: testType)
        }
        .sheet(item: $selectedResult) { result in
            TestResultDetailView(result: result)
        }
        .navigationDestination(isPresented: $showAllHistory) {
            AllScreeningsView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: – Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Check Your Vision")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(Color.aveoText)
            Text("6 standardized screening tests")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var disclaimerBanner: some View {
        DisclosureGroup(isExpanded: $disclaimerExpanded) {
            Text("These are screening tools, not medical diagnoses. See an eye care professional for a comprehensive exam.")
                .font(.system(size: 11))
                .foregroundStyle(Color.aveoText2)
                .padding(.top, 4)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.aveoWarning)
                Text("Medical Disclaimer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.aveoWarning)
            }
        }
        .tint(Color.aveoWarning)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aveoWarning.opacity(0.05))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.aveoWarning.opacity(0.15), lineWidth: 0.5)
        }
        .aveoShadowSm()
    }

    // MARK: – Test Grid

    private var testGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(VisionTestType.allCases) { testType in
                testCard(testType)
            }
        }
    }

    private func testCard(_ testType: VisionTestType) -> some View {
        let lastResult = results.first { $0.testType == testType.rawValue }
        let isLocked = !testType.isFree && !appState.isPremium

        return Button {
            HapticManager.selection()
            if isLocked {
                showPaywall = true
            } else {
                selectedTest = testType
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(testType.color.opacity(isLocked ? 0.06 : 0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: isLocked ? "lock.fill" : testType.icon)
                        .font(.system(size: isLocked ? 13 : 15))
                        .foregroundStyle(isLocked ? Color.aveoGold : testType.color)
                }

                Text(testType.displayName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isLocked ? Color.aveoText3 : Color.aveoText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                if isLocked {
                    Text("PRO")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.aveoGold)
                } else {
                    Text(testType.durationLabel)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.aveoText3)
                }

                if !isLocked, let result = lastResult {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(result.passed ? Color.aveoSuccess : Color.aveoWarning)
                            .frame(width: 4, height: 4)
                        Text(result.passed ? NSLocalizedString("Normal", comment: "") : NSLocalizedString("Review", comment: ""))
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(result.passed ? Color.aveoSuccess : Color.aveoWarning)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 14, padding: 0)
        }
        .buttonStyle(.pressScale)
        .accessibilityLabel("\(testType.displayName) test, \(isLocked ? "Premium" : testType.durationLabel)")
        .accessibilityHint(isLocked ? "Double tap to view premium options" : "Double tap to start screening")
    }

    // MARK: – Test History (single consolidated block)

    @ViewBuilder
    private var recentResults: some View {
        if !results.isEmpty {
            let passedCount = results.filter(\.passed).count
            let failedCount = results.count - passedCount
            let lastResult = results.first

            Button {
                HapticManager.selection()
                showAllHistory = true
            } label: {
                VStack(spacing: 10) {
                    // Header row
                    HStack {
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.linearGradient(
                                colors: [.aveoData, Color(hex: 0x1D4ED8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))

                        Text("TEST HISTORY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.aveoText3)
                            .kerning(0.8)

                        Spacer()

                        Text("\(results.count)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.aveoText)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.aveoText3)
                    }

                    // Status summary
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.aveoSuccess)
                                .frame(width: 6, height: 6)
                            Text("\(passedCount) Normal")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.aveoSuccess)
                        }

                        if failedCount > 0 {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.aveoWarning)
                                    .frame(width: 6, height: 6)
                                Text("\(failedCount) Review")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.aveoWarning)
                            }
                        }

                        Spacer()
                    }

                    // Last test preview
                    if let last = lastResult {
                        let testType = VisionTestType(rawValue: last.testType)
                        HStack(spacing: 8) {
                            Image(systemName: testType?.icon ?? "eye")
                                .font(.system(size: 11))
                                .foregroundStyle(testType?.color ?? .aveoText3)

                            Text("Last: \(testType?.displayName ?? last.testType)")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.aveoText2)

                            Spacer()

                            Text(last.timestamp, style: .date)
                                .font(.system(size: 9))
                                .foregroundStyle(Color.aveoText3)
                        }
                    }
                }
                .padding(12)
                .glassCard(cornerRadius: 14, padding: 0)
            }
            .buttonStyle(.pressScale)
        }
    }
}

#Preview {
    NavigationStack {
        ScreeningListView()
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
