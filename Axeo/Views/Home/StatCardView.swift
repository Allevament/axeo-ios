import SwiftUI

/// A single animated stat display used in the Home screen stat grid.
struct StatCardView: View {
    let label: String
    let value: Int
    let suffix: String
    let color: Color

    @State private var displayValue: Int = 0

    var body: some View {
        VStack(spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(displayValue)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())

                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(color.opacity(0.7))
                }
            }

            Text(label.uppercased())
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14, padding: 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                displayValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeOut(duration: 0.4)) {
                displayValue = newValue
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCardView(label: "Workouts", value: 3, suffix: "", color: .aveoTeal)
        StatCardView(label: "Focus", value: 87, suffix: "%", color: .aveoAccent)
    }
    .padding()
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
