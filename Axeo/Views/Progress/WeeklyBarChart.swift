import SwiftUI

/// Multi-range bar chart: Week · 30 Days · 90 Days
struct WeeklyBarChart: View {
    let sessions: [Session]

    enum ChartRange: String, CaseIterable {
        case week = "Week"
        case month = "30 Days"
        case quarter = "90 Days"

        var localizedName: String {
            NSLocalizedString(rawValue, comment: "")
        }
    }

    @State private var range: ChartRange = .week
    @State private var appeared = false
    @State private var selectedBarIndex: Int? = nil

    var body: some View {
        VStack(spacing: 14) {
            // Range picker
            Picker("Range", selection: $range) {
                ForEach(ChartRange.allCases, id: \.self) { r in
                    Text(r.localizedName).tag(r)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: range) { _, _ in
                selectedBarIndex = nil
                appeared = false
                withAnimation(.spring(duration: 0.5)) {
                    appeared = true
                }
            }

            // Summary
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: NSLocalizedString("%d workouts", comment: ""), totalForRange))
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.aveoText)
                    Text(String(format: NSLocalizedString("%d minutes", comment: ""), minutesForRange))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                Spacer()
            }

            // Tooltip
            if let idx = selectedBarIndex, idx < barData.count {
                let entry = barData[idx]
                HStack(spacing: 6) {
                    Text(entry.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.aveoText)
                    Text("·")
                        .foregroundStyle(Color.aveoText3)
                    Text(String(format: entry.count == 1 ? NSLocalizedString("%d workout", comment: "") : NSLocalizedString("%d workouts", comment: ""), entry.count))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.aveoTeal)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule().fill(Color.aveoGlass)
                        }
                }
                .overlay {
                    Capsule().strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
                }
                .aveoShadowSm()
                .transition(.opacity)
            }

            // Bars
            HStack(alignment: .bottom, spacing: range == .quarter ? 4 : 8) {
                ForEach(barData.indices, id: \.self) { i in
                    barColumn(index: i)
                }
            }
            .frame(height: 110)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedBarIndex)
    }

    // MARK: – Bar Column

    private func barColumn(index i: Int) -> some View {
        let entry = barData[i]
        let maxVal = max(barData.map(\.count).max() ?? 1, 1)
        let height: CGFloat = entry.count > 0
            ? CGFloat(entry.count) / CGFloat(maxVal) * 80
            : 4.0
        let isSelected = selectedBarIndex == i

        return VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    entry.count > 0
                        ? LinearGradient(colors: [.aveoTeal, .aveoAccent], startPoint: .bottom, endPoint: .top)
                        : LinearGradient(colors: [Color.aveoText3.opacity(0.15)], startPoint: .bottom, endPoint: .top)
                )
                .frame(height: appeared ? height : 0)
                .opacity(isSelected ? 1.0 : (selectedBarIndex == nil ? 1.0 : 0.5))

            if entry.count > 0 && range == .week {
                Text("\(entry.count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.aveoTeal)
            }

            Text(entry.shortLabel)
                .font(.system(size: range == .quarter ? 8 : 10, weight: entry.isToday ? .bold : .regular))
                .foregroundStyle(entry.isToday ? Color.aveoText : Color.aveoText3)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.selection()
            withAnimation {
                selectedBarIndex = selectedBarIndex == i ? nil : i
            }
        }
    }

    // MARK: – Data Model

    private struct BarEntry {
        let label: String
        let shortLabel: String
        let count: Int
        let isToday: Bool
    }

    private var barData: [BarEntry] {
        switch range {
        case .week:   weekBars
        case .month:  monthBars
        case .quarter: quarterBars
        }
    }

    private var totalForRange: Int {
        barData.reduce(0) { $0 + $1.count }
    }

    private var minutesForRange: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let daysBack: Int
        switch range {
        case .week:    daysBack = 7
        case .month:   daysBack = 30
        case .quarter: daysBack = 90
        }
        guard let start = cal.date(byAdding: .day, value: -daysBack, to: today) else { return 0 }
        return sessions.filter { $0.startedAt >= start }.reduce(0) { $0 + $1.totalDurationSec } / 60
    }

    // MARK: – Week Bars

    private var weekBars: [BarEntry] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let weekday = cal.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        guard let monday = cal.date(byAdding: .day, value: -mondayOffset, to: today) else {
            return []
        }
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let todayIdx = mondayOffset

        return (0..<7).map { i in
            let dayStart = cal.date(byAdding: .day, value: i, to: monday)!
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
            let count = sessions.filter { $0.startedAt >= dayStart && $0.startedAt < dayEnd }.count
            return BarEntry(label: labels[i], shortLabel: labels[i], count: count, isToday: i == todayIdx)
        }
    }

    // MARK: – 30-Day Bars

    private var monthBars: [BarEntry] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let fmt = DateFormatter()
        fmt.dateFormat = "d"

        return (0..<30).map { offset in
            let daysAgo = 29 - offset
            let dayStart = cal.date(byAdding: .day, value: -daysAgo, to: today)!
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
            let count = sessions.filter { $0.startedAt >= dayStart && $0.startedAt < dayEnd }.count
            let showLabel = offset % 5 == 0 || offset == 29
            let label = fmt.string(from: dayStart)
            return BarEntry(
                label: dayStart.formatted(.dateTime.month(.abbreviated).day()),
                shortLabel: showLabel ? label : "",
                count: count,
                isToday: daysAgo == 0
            )
        }
    }

    // MARK: – 90-Day (Weekly Buckets)

    private var quarterBars: [BarEntry] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        return (0..<12).map { weekIdx in
            let weeksAgo = 11 - weekIdx
            let weekStart = cal.date(byAdding: .day, value: -(weeksAgo + 1) * 7, to: today)!
            let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)!
            let count = sessions.filter { $0.startedAt >= weekStart && $0.startedAt < weekEnd }.count
            return BarEntry(
                label: "W\(weekIdx + 1)",
                shortLabel: "W\(weekIdx + 1)",
                count: count,
                isToday: weeksAgo == 0
            )
        }
    }
}

#Preview {
    WeeklyBarChart(sessions: [])
        .padding()
        .background(Color.aveoBg)
        .preferredColorScheme(.dark)
}
