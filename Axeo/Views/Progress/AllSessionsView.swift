import SwiftUI
import SwiftData

struct AllSessionsView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Session.endedAt, order: .reverse) private var allSessions: [Session]

    private var user: User? { appState.currentUser }

    private var userSessions: [Session] {
        guard let uid = user?.id else { return [] }
        return allSessions.filter { $0.userId == uid }
    }

    @State private var filter: SessionFilter = .all

    enum SessionFilter: String, CaseIterable {
        case all = "All"
        case completed = "Completed"
        case incomplete = "Incomplete"

        var localizedName: String { NSLocalizedString(rawValue, comment: "") }
    }

    private var filtered: [Session] {
        switch filter {
        case .all:        userSessions
        case .completed:  userSessions.filter(\.completed)
        case .incomplete: userSessions.filter { !$0.completed }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Summary strip
                summaryStrip

                // Filter
                Picker("Filter", selection: $filter) {
                    ForEach(SessionFilter.allCases, id: \.self) { f in
                        Text(f.localizedName).tag(f)
                    }
                }
                .pickerStyle(.segmented)

                // List
                if filtered.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filtered) { session in
                            sessionCard(session)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AmbientBackground())
        .navigationTitle("All Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryStrip: some View {
        let completed = userSessions.filter(\.completed)
        let totalMin = completed.reduce(0) { $0 + $1.totalDurationSec } / 60
        let avgAccVals = completed.compactMap(\.accuracy)
        let avgAcc = avgAccVals.isEmpty ? 0 : avgAccVals.reduce(0, +) / avgAccVals.count

        return HStack(spacing: 0) {
            miniStat("\(completed.count)", label: NSLocalizedString("Done", comment: ""), color: .aveoSuccess)
            miniStat("\(totalMin)m", label: NSLocalizedString("Total", comment: ""), color: .aveoAccent)
            miniStat(avgAcc > 0 ? "\(avgAcc)%" : "—", label: NSLocalizedString("Focus", comment: ""), color: .aveoTeal)
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

    private func sessionCard(_ session: Session) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(session.completed ? Color.aveoSuccess.opacity(0.1) : Color.aveoText3.opacity(0.08))
                    .frame(width: 32, height: 32)
                Image(systemName: session.completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(session.completed ? Color.aveoSuccess : Color.aveoText3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sessionTypeLabel(session.sessionType))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.aveoText)

                HStack(spacing: 4) {
                    Text(String(format: NSLocalizedString("%d exercises", comment: ""), session.exerciseCount))
                    Text("·")
                    Text("\(session.totalDurationSec / 60)m \(session.totalDurationSec % 60)s")
                }
                .font(.system(size: 9))
                .foregroundStyle(Color.aveoText3)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let acc = session.accuracy {
                    Text("\(acc)%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.aveoTeal)
                }
                Text(session.endedAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.system(size: 8))
                    .foregroundStyle(Color.aveoText3)
            }
        }
        .padding(10)
        .glassCard(cornerRadius: 12, padding: 0)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.run")
                .font(.system(size: 28))
                .foregroundStyle(Color.aveoText3.opacity(0.4))
            Text("No sessions yet")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
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
        AllSessionsView()
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
