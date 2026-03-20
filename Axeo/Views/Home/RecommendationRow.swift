import SwiftUI

struct RecommendationRow: View {
    let exercise: ExerciseDefinition
    let rank: Int
    let isDone: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.light()
            onTap()
        }) {
            HStack(spacing: 10) {
                // Rank badge
                Text("\(rank)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(Color.aveoAccent.opacity(isDone ? 0.3 : 0.7))
                    )

                // Exercise icon
                Image(systemName: exercise.sfSymbol)
                    .font(.system(size: 15))
                    .foregroundStyle(exercise.motionType.category.color)
                    .frame(width: 32, height: 32)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(exercise.motionType.category.color.opacity(0.12))
                    }

                // Name + meta
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoText)

                    Text("\(exercise.duration)s · \(isDone ? "Done" : "Not done yet")")
                        .font(.aveoCaption)
                        .foregroundStyle(isDone ? Color.aveoSuccess : Color.aveoWarning)
                }

                Spacer()

                // Play icon
                Image(systemName: isDone ? "checkmark.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(isDone ? Color.aveoSuccess : Color.aveoAccent)
            }
            .padding(10)
            .glassCard(cornerRadius: 14, padding: 0)
        }
        .buttonStyle(.pressScale)
    }
}

#Preview {
    VStack(spacing: 8) {
        RecommendationRow(exercise: ExerciseDefinition.all[0], rank: 1, isDone: false) { }
        RecommendationRow(exercise: ExerciseDefinition.all[1], rank: 2, isDone: true) { }
    }
    .padding()
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
