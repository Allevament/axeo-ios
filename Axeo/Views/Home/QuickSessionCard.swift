import SwiftUI

struct QuickSessionCard: View {
    let exerciseCount: Int
    let estimatedMinutes: Int
    let onStart: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: {
            HapticManager.medium()
            onStart()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    // Lightning icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.aveoRetinal.opacity(0.25), Color.aveoRetinal.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)

                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.aveoRetinal)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Eye Workout")
                            .font(.aveoHeadline)
                            .foregroundStyle(Color.aveoText)

                        Text(String(format: NSLocalizedString("%d exercises · %d min · doctor-recommended", comment: ""), exerciseCount, estimatedMinutes))
                            .font(.aveoCaption)
                            .foregroundStyle(Color.aveoText2)
                    }
                }

                // Start button
                HStack {
                    Spacer()
                    Label("Start Workout", systemImage: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.aveoBg)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(
                    LinearGradient.aveoTealGradient,
                    in: Capsule()
                )
                .scaleEffect(pulse ? 1.015 : 1.0)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.aveoGlass)
                    }
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.aveoGlassHighlight, .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.aveoTeal.opacity(0.2), lineWidth: 0.5)
            }
            .aveoShadowMd()
        }
        .buttonStyle(.pressScale)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily Eye Workout. \(exerciseCount) exercises, \(estimatedMinutes) minutes.")
        .accessibilityHint("Double tap to start your workout")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

#Preview {
    QuickSessionCard(exerciseCount: 5, estimatedMinutes: 5) { }
        .padding()
        .background(Color.aveoBg)
        .preferredColorScheme(.dark)
}
