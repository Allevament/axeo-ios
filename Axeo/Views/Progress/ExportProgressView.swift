import SwiftUI
import SwiftData

/// Export progress detail screen — styled like the Achievements tab.
/// Shows a summary of all stats and provides Share / Save options.
struct ExportProgressView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Session.endedAt, order: .reverse) private var allSessions: [Session]
    @Query(sort: \VisionTestResult.timestamp, order: .reverse) private var testResults: [VisionTestResult]

    @State private var appeared = false
    @State private var exported = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

    private var user: User? { appState.currentUser }

    private var completedSessions: [Session] {
        guard let uid = user?.id else { return [] }
        return allSessions.filter { $0.userId == uid && $0.completed }
    }

    private var totalMinutes: Int {
        completedSessions.reduce(0) { $0 + $1.totalDurationSec } / 60
    }

    private var totalExercises: Int {
        completedSessions.reduce(0) { $0 + $1.exerciseCount }
    }

    private var avgAccuracy: Int {
        let vals = completedSessions.compactMap(\.accuracy)
        return vals.isEmpty ? 0 : vals.reduce(0, +) / vals.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroSection
                statsSummary
                dataBreakdown
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AmbientBackground())
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !appeared else { return }
            withAnimation(.spring(duration: 0.5)) { appeared = true }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.aveoTeal.opacity(0.12), Color.aveoAccent.opacity(0.06), .clear],
                            center: .center,
                            startRadius: 16,
                            endRadius: 56
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)

                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.linearGradient(
                        colors: [.aveoTeal, .aveoAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .scaleEffect(appeared ? 1 : 0.4)
                    .opacity(appeared ? 1 : 0)
            }

            Text("Your Progress Report")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
                .opacity(appeared ? 1 : 0)

            Text(user?.displayName ?? "Axeo User")
                .font(.system(size: 11))
                .foregroundStyle(Color.aveoText3)
                .opacity(appeared ? 1 : 0)
        }
        .padding(.top, 8)
    }

    // MARK: – Stats Summary

    private var statsSummary: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

        return LazyVGrid(columns: columns, spacing: 10) {
            exportStat(value: "\(completedSessions.count)", label: "Workouts", icon: "figure.run", gradient: [.aveoTeal, .aveoAccent])
            exportStat(value: "\(totalMinutes)", label: "Minutes", icon: "timer", gradient: [.aveoAccent, Color(hex: 0x0088CC)])
            exportStat(value: "\(totalExercises)", label: "Exercises", icon: "eye.fill", gradient: [.aveoGold, .aveoRetinal])
            exportStat(value: avgAccuracy > 0 ? "\(avgAccuracy)%" : "—", label: "Avg Focus", icon: "scope", gradient: [.aveoSuccess, Color(hex: 0x0EA47A)])
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
    }

    private func exportStat(value: String, label: String, icon: String, gradient: [Color]) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.linearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                Spacer()
            }
            HStack {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.aveoText)
                Spacer()
            }
            HStack {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.aveoText3)
                Spacer()
            }
        }
        .padding(10)
        .glassCard(cornerRadius: 12, padding: 0)
    }

    // MARK: – Data Breakdown

    private var dataBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INCLUDED DATA")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            dataRow(icon: "list.bullet.rectangle.portrait.fill", label: "Training Sessions", count: completedSessions.count, color: .aveoTeal)
            dataRow(icon: "waveform.path.ecg.rectangle.fill", label: "Vision Screenings", count: testResults.count, color: .aveoData)
            dataRow(icon: "calendar", label: "Date Range", detail: dateRange, color: .aveoAccent)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    private func dataRow(icon: String, label: String, count: Int? = nil, detail: String? = nil, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 26, height: 26)
                .background {
                    RoundedRectangle(cornerRadius: 7).fill(color.opacity(0.1))
                }

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.aveoText)

            Spacer()

            if let count {
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            if let detail {
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.aveoText3)
            }
        }
        .padding(10)
        .glassCard(cornerRadius: 12, padding: 0)
    }

    private var dateRange: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        let earliest = completedSessions.last?.startedAt ?? testResults.last?.timestamp
        let latest = completedSessions.first?.startedAt ?? testResults.first?.timestamp
        guard let start = earliest, let end = latest else { return "No data" }
        return "\(fmt.string(from: start)) — \(fmt.string(from: end))"
    }

    // MARK: – Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            // Share as text summary
            Button {
                HapticManager.medium()
                shareTextSummary()
            } label: {
                Label("Share Summary", systemImage: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.aveoBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient.aveoTealGradient,
                        in: Capsule()
                    )
                    .shadow(color: Color.aveoTeal.opacity(0.25), radius: 12, y: 4)
            }

            // Export JSON file
            Button {
                HapticManager.medium()
                exportJSON()
            } label: {
                Label("Save as JSON", systemImage: "doc.badge.arrow.up.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.aveoTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glassCard(cornerRadius: 12, padding: 0)
            }
            .buttonStyle(.pressScale)

            if exported {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.aveoSuccess)
                    Text("Ready to share")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.aveoSuccess)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
    }

    // MARK: – Export Actions

    private func shareTextSummary() {
        let name = user?.displayName ?? "Axeo User"
        let summary = """
        \(name)'s Axeo Progress Report
        \(String(repeating: "—", count: 30))
        Workouts completed: \(completedSessions.count)
        Total training time: \(totalMinutes) minutes
        Exercises performed: \(totalExercises)
        Average focus score: \(avgAccuracy > 0 ? "\(avgAccuracy)%" : "N/A")
        Vision screenings: \(testResults.count)
        \(String(repeating: "—", count: 30))
        Generated by Axeo — Structured eye-training routines
        """

        presentShareSheet(items: [summary])
    }

    private func exportJSON() {
        struct ExportSession: Codable {
            let date: String
            let type: String
            let exerciseCount: Int
            let durationSec: Int
            let accuracy: Int?
            let completed: Bool
        }
        struct ExportTest: Codable {
            let date: String
            let type: String
            let passed: Bool
            let summary: String
        }
        struct ExportPayload: Codable {
            let exportedAt: String
            let userName: String
            let sessions: [ExportSession]
            let testResults: [ExportTest]
        }

        let fmt = ISO8601DateFormatter()
        let payload = ExportPayload(
            exportedAt: fmt.string(from: .now),
            userName: user?.displayName ?? "Axeo User",
            sessions: completedSessions.map {
                ExportSession(
                    date: fmt.string(from: $0.startedAt),
                    type: sessionTypeLabel($0.sessionType),
                    exerciseCount: $0.exerciseCount,
                    durationSec: $0.totalDurationSec,
                    accuracy: $0.accuracy,
                    completed: $0.completed
                )
            },
            testResults: testResults.map {
                ExportTest(
                    date: fmt.string(from: $0.timestamp),
                    type: $0.testType,
                    passed: $0.passed,
                    summary: $0.summary
                )
            }
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(payload)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("axeo-progress.json")
            try data.write(to: url)
            presentShareSheet(items: [url])
        } catch {
            print("[Export] Error: \(error)")
        }
    }

    private func presentShareSheet(items: [Any]) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController else { return }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                withAnimation(.spring(duration: 0.3)) {
                    exported = true
                }
                HapticManager.success()
            }
        }

        // iPad popover support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = root.view
            popover.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        root.present(activityVC, animated: true)
    }

    private func sessionTypeLabel(_ type: Session.SessionType) -> String {
        switch type {
        case .quick:  NSLocalizedString("Quick Workout", comment: "")
        case .single: NSLocalizedString("Single Exercise", comment: "")
        case .course: NSLocalizedString("Program Session", comment: "")
        }
    }
}

#Preview {
    NavigationStack {
        ExportProgressView()
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
