import SwiftUI

// MARK: – Stat Item

struct StatItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let color: Color

    init(_ label: String, value: String, color: Color = .aveoTeal) {
        self.label = label
        self.value = value
        self.color = color
    }
}

// MARK: – Stat Grid View

struct StatGridView: View {
    let items: [StatItem]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items) { item in
                StatCell(item: item)
            }
        }
    }
}

// MARK: – Single Stat Cell

private struct StatCell: View {
    let item: StatItem
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 6) {
            Text(item.value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(item.color)
                .contentTransition(.numericText())

            Text(item.label.uppercased())
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 14, padding: 0)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                appeared = true
            }
        }
    }
}

#Preview {
    StatGridView(items: [
        StatItem("Workouts", value: "3", color: .aveoTeal),
        StatItem("Focus Score", value: "87%", color: .aveoAccent),
        StatItem("Time", value: "12m", color: .aveoGold),
        StatItem("Exercises", value: "15", color: .aveoSuccess),
    ])
    .padding()
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
