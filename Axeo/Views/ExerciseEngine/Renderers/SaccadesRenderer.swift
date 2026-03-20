import SwiftUI

/// Ex 3 – Saccades: Dot appears at one of 9 grid positions.
/// User snaps gaze to it and holds for ~2.5 seconds.
struct SaccadesRenderer: View, ExerciseRendering {
    let progress: Double
    let isPaused: Bool
    let duration: Int

    // Change position every 2.5 seconds
    private var currentSlot: Int {
        let elapsed = progress * Double(duration)
        return Int(elapsed / 2.5) % 9
    }

    // Fixed grid positions (3×3)
    private let gridPositions: [(CGFloat, CGFloat)] = [
        (0.2, 0.25), (0.5, 0.25), (0.8, 0.25),
        (0.2, 0.45), (0.5, 0.45), (0.8, 0.45),
        (0.2, 0.65), (0.5, 0.65), (0.8, 0.65),
    ]

    // Deterministic sequence (not random — repeatable)
    private let sequence = [4, 0, 8, 2, 6, 1, 7, 3, 5, 4, 2, 6, 0, 8, 1, 7, 5, 3]

    private var activePosition: Int {
        sequence[currentSlot % sequence.count]
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size

            ZStack {
                // Grid ghost dots
                ForEach(0..<9, id: \.self) { i in
                    let pos = gridPositions[i]
                    let isActive = i == activePosition

                    Circle()
                        .fill(isActive ? Color.aveoAccent : Color.aveoText3.opacity(0.15))
                        .frame(width: isActive ? 32 : 12, height: isActive ? 32 : 12)
                        .shadow(color: isActive ? .aveoAccent.opacity(0.5) : .clear, radius: 12)
                        .position(
                            x: size.width * pos.0,
                            y: size.height * pos.1
                        )
                        .animation(.spring(duration: 0.3, bounce: 0.3), value: isActive)
                }

                // Crosshair on active
                let activePos = gridPositions[activePosition]
                Group {
                    Rectangle()
                        .fill(Color.aveoAccent.opacity(0.1))
                        .frame(width: 1, height: 30)
                    Rectangle()
                        .fill(Color.aveoAccent.opacity(0.1))
                        .frame(width: 30, height: 1)
                }
                .position(
                    x: size.width * activePos.0,
                    y: size.height * activePos.1
                )

                VStack {
                    Spacer()
                    Text(NSLocalizedString("Snap your gaze to the dot", comment: ""))
                        .font(.aveoCaption)
                        .foregroundStyle(Color.aveoText3)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
