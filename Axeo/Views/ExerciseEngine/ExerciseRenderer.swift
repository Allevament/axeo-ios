import SwiftUI

// MARK: – Renderer Protocol

/// Every exercise renderer conforms to this.
/// The engine drives `progress` (0→1) and calls `onComplete`.
protocol ExerciseRendering: View {
    var progress: Double { get }
    var isPaused: Bool { get }
}

// MARK: – Router

/// Given a `MotionType`, returns the correct renderer view.
struct ExerciseRendererRouter: View {
    let motionType: MotionType
    let progress: Double
    let isPaused: Bool
    let duration: Int

    var body: some View {
        switch motionType {
        case .focus:      FocusShiftRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .eight:      FigureEightRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .palm:       PalmingRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .fixate:     SaccadesRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .blink:      BlinkingRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .mark:       WindowDotRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .converge:   ConvergenceRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .square:     SquareTracingRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .lines:      LinesRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .warmth:     WarmCompressRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .stereo:     StereogramRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .fusion:     ImageFusionRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .breath:     BreathGazeRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .rule20:     Rule2020Renderer(progress: progress, isPaused: isPaused, duration: duration)
        case .lidmassage: LidMassageRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .lidgym:     LidGymRenderer(progress: progress, isPaused: isPaused, duration: duration)
        case .tearfilm:   TearFilmRenderer(progress: progress, isPaused: isPaused, duration: duration)
        }
    }
}
