import SwiftUI

struct ExerciseDetailView: View {
    let exercise: ExerciseDefinition
    @Environment(\.dismiss) private var dismiss
    @State private var stepsAppeared = false
    @State private var showActiveExercise = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroSection
                badgesSection
                stepsSection
                indicationsSection
                disclaimerSection
                startButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AmbientBackground())
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .fullScreenCover(isPresented: $showActiveExercise) {
            ExerciseActiveView(
                exercises: [exercise],
                sessionType: .single,
                courseId: nil
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                stepsAppeared = true
            }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(exercise.motionType.category.color.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: exercise.sfSymbol)
                    .font(.system(size: 40))
                    .foregroundStyle(exercise.motionType.category.color)
            }
            .padding(.top, 8)

            Text(exercise.name)
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)
        }
    }

    // MARK: – Badges

    private var badgesSection: some View {
        FlowLayout(spacing: 8) {
            badge(String(format: NSLocalizedString("Takes about %d seconds", comment: ""), exercise.duration), icon: "clock", color: .aveoTeal)
            badge(exercise.cvEnabled ? NSLocalizedString("Eye Tracking", comment: "") : NSLocalizedString("Eye Tracking Coming Soon", comment: ""),
                  icon: "viewfinder", color: exercise.cvEnabled ? .aveoSuccess : .aveoText3)
            badge(NSLocalizedString("Educational eye-care content", comment: ""), icon: "stethoscope", color: .aveoAccent2)
        }
    }

    private func badge(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .overlay { Capsule().fill(color.opacity(0.08)) }
        }
        .overlay {
            Capsule().strokeBorder(color.opacity(0.15), lineWidth: 0.5)
        }
    }

    // MARK: – Steps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("HOW TO DO IT")
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background {
                                Circle().fill(exercise.motionType.category.color)
                            }

                        Text(step)
                            .font(.aveoBody)
                            .foregroundStyle(Color.aveoText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .opacity(stepsAppeared ? 1 : 0)
                    .offset(y: stepsAppeared ? 0 : 12)
                    .animation(
                        .easeOut(duration: 0.4).delay(Double(index) * 0.12),
                        value: stepsAppeared
                    )
                }
            }
        }
        .glassCard(cornerRadius: 16, padding: 16)
    }

    // MARK: – Indications

    private var indicationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHO IT HELPS")
                .font(.aveoOverline)
                .foregroundStyle(Color.aveoText3)
                .padding(.leading, 4)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.aveoAccent)
                Text(exercise.indications)
                    .font(.aveoBody)
                    .foregroundStyle(Color.aveoText2)
            }
        }
        .glassCard(cornerRadius: 16, padding: 16)
    }

    // MARK: – Disclaimer

    private var disclaimerSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "stethoscope")
                .font(.system(size: 14))
                .foregroundStyle(Color.aveoText3)

            Text("Educational eye-care content for general wellness. Not a medical device or treatment. Consult an eye care professional if you have a pre-existing condition.")
                .font(.system(size: 12))
                .foregroundStyle(Color.aveoText3)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.aveoGlass)
                }
        }
    }

    // MARK: – Start Button

    private var startButton: some View {
        Button {
            HapticManager.medium()
            showActiveExercise = true
        } label: {
            Label("Start Exercise", systemImage: "play.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.aveoBg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient.aveoAccentGradient,
                    in: Capsule()
                )
                .shadow(color: Color.aveoAccent.opacity(0.3), radius: 16, y: 4)
        }
    }
}

// MARK: – Flow Layout (horizontal wrapping)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: ExerciseDefinition.all[1])
    }
    .preferredColorScheme(.dark)
}
