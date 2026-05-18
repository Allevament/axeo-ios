import SwiftUI
import SwiftData

/// The full-screen exercise player. Drives the timer, renders the active exercise,
/// handles pause overlay, between-exercise transitions, and end session.
/// Integrates ARKit eye tracking for focus scoring on supported devices.
struct ExerciseActiveView: View {
    let exercises: [ExerciseDefinition]
    let sessionType: Session.SessionType
    let courseId: UUID?

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: – State

    @State private var currentIndex = 0
    @State private var progress: Double = 0
    @State private var isPaused = false
    @State private var showBetween = false
    @State private var sessionStartedAt = Date.now
    @State private var showResult = false
    @State private var resultSession: Session?
    @State private var showEndConfirm = false

    // Eye tracking
    @State private var eyeTracker = EyeTrackingManager()

    // Timer
    @State private var timer: Timer?
    private let tickInterval: TimeInterval = 1.0 / 60.0 // 60 fps

    private var currentExercise: ExerciseDefinition {
        exercises[currentIndex]
    }

    private var remainingSeconds: Int {
        max(0, Int(Double(currentExercise.duration) * (1.0 - progress)))
    }

    private var totalElapsedSeconds: Int {
        let pastDuration = exercises.prefix(currentIndex).reduce(0) { $0 + $1.duration }
        let currentElapsed = Int(Double(currentExercise.duration) * progress)
        return pastDuration + currentElapsed
    }

    // MARK: – Body

    var body: some View {
        ZStack {
            Color.aveoBg.ignoresSafeArea()

            if showResult, let session = resultSession {
                // Inline result screen. Done → dismiss the whole exercise flow.
                SessionResultView(session: session, courseId: courseId) {
                    dismiss()
                }
                .transition(.opacity)
            } else if showBetween {
                betweenExerciseView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                exercisePlayerView
            }

            if isPaused && !showBetween && !showResult {
                pauseOverlay
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            startTimer()
            // Start eye tracking if the device supports it and exercise uses CV
            if eyeTracker.isSupported && currentExercise.cvEnabled {
                eyeTracker.start()
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stopTimer()
            eyeTracker.stop()
        }
        .confirmationDialog("End Session?", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("End Session", role: .destructive) {
                endSessionEarly()
            }
            Button("Cancel", role: .cancel) {
                isPaused = false
            }
        } message: {
            Text("Your progress in this exercise will be saved.")
        }
    }

    // MARK: – Exercise Player

    private var exercisePlayerView: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar

            // Renderer area
            ExerciseRendererRouter(
                motionType: currentExercise.motionType,
                progress: progress,
                isPaused: isPaused,
                duration: currentExercise.duration
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom controls
            bottomControls
        }
    }

    private var topBar: some View {
        HStack {
            // Exercise info
            VStack(alignment: .leading, spacing: 2) {
                Text(currentExercise.name)
                    .font(.aveoHeadline)
                    .foregroundStyle(Color.aveoText)
                Text(String(format: NSLocalizedString("%d of %d", comment: ""), currentIndex + 1, exercises.count))
                    .font(.aveoCaption)
                    .foregroundStyle(Color.aveoText3)
            }

            Spacer()

            // Eye tracking indicator
            if eyeTracker.isTracking {
                HStack(spacing: 4) {
                    Circle()
                        .fill(eyeTracker.isBlinking ? Color.aveoWarning : Color.aveoSuccess)
                        .frame(width: 6, height: 6)
                    Text("\(Int(eyeTracker.gazeOnTarget * 100))%")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.aveoSuccess)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule().fill(.ultraThinMaterial)
                }
                .overlay {
                    Capsule().fill(Color.aveoGlass)
                }
                .overlay {
                    Capsule().strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
                }
            }

            // Timer
            Text(formatTime(remainingSeconds))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.aveoTeal)
                .monospacedDigit()
                .accessibilityLabel("\(remainingSeconds) seconds remaining")
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.aveoText3.opacity(0.15))
                        .frame(height: 4)

                    Capsule()
                        .fill(LinearGradient.aveoTealGradient)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)

            // Buttons
            HStack(spacing: 24) {
                // End session
                Button {
                    HapticManager.light()
                    isPaused = true
                    showEndConfirm = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.aveoError.opacity(0.7))
                }
                .accessibilityLabel("End session")

                Spacer()

                // Pause / Play
                Button {
                    HapticManager.medium()
                    withAnimation(.spring(duration: 0.3)) {
                        isPaused.toggle()
                    }
                } label: {
                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.aveoTeal)
                }
                .accessibilityLabel(isPaused ? "Resume exercise" : "Pause exercise")

                Spacer()

                // Skip
                Button {
                    HapticManager.light()
                    skipToNext()
                } label: {
                    Image(systemName: "forward.end.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.aveoAccent2.opacity(0.7))
                }
                .accessibilityLabel("Skip to next exercise")
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
    }

    // MARK: – Between Exercise

    private var betweenExerciseView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.aveoSuccess)

            Text("Great work!")
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)

            if currentIndex < exercises.count {
                let next = exercises[currentIndex]

                VStack(spacing: 8) {
                    Text("Up next")
                        .font(.aveoOverline)
                        .foregroundStyle(Color.aveoText3)

                    HStack(spacing: 12) {
                        Image(systemName: next.sfSymbol)
                            .font(.system(size: 24))
                            .foregroundStyle(next.motionType.category.color)
                            .frame(width: 48, height: 48)
                            .background {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(next.motionType.category.color.opacity(0.12))
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(next.name)
                                .font(.aveoHeadline)
                                .foregroundStyle(Color.aveoText)
                            Text(String(format: NSLocalizedString("%d seconds", comment: ""), next.duration))
                                .font(.aveoCaption)
                                .foregroundStyle(Color.aveoText2)
                        }
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 16, padding: 0)
                }
                .padding(.horizontal, 40)
            }

            Spacer()

            Text("Starting in 3 seconds…")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)
                .padding(.bottom, 40)
        }
    }

    // MARK: – Pause Overlay

    private var pauseOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Paused")
                    .font(.aveoLargeTitle)
                    .foregroundStyle(Color.aveoText)

                Button {
                    HapticManager.medium()
                    withAnimation(.spring(duration: 0.3)) {
                        isPaused = false
                    }
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .font(.aveoHeadline)
                        .foregroundStyle(Color.aveoBg)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient.aveoTealGradient,
                            in: Capsule()
                        )
                        .shadow(color: Color.aveoTeal.opacity(0.3), radius: 16, y: 4)
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: – Timer Logic

    private func startTimer() {
        sessionStartedAt = .now
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            guard !isPaused && !showBetween else { return }

            let increment = tickInterval / Double(currentExercise.duration)
            progress += increment

            if progress >= 1.0 {
                exerciseComplete()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func exerciseComplete() {
        AudioManager.playBeep()
        HapticManager.success()

        let nextIndex = currentIndex + 1

        if nextIndex >= exercises.count {
            // Session complete
            saveSession(completed: true)
            return
        }

        // Show between-exercise transition
        currentIndex = nextIndex
        progress = 0

        // Reset eye tracker for next exercise; start/stop based on cvEnabled
        if eyeTracker.isSupported {
            let nextExercise = exercises[currentIndex]
            if nextExercise.cvEnabled && !eyeTracker.isTracking {
                eyeTracker.start()
            } else if !nextExercise.cvEnabled && eyeTracker.isTracking {
                eyeTracker.stop()
            } else {
                eyeTracker.reset()
            }
        }

        withAnimation(.spring(duration: 0.4)) {
            showBetween = true
        }

        // Auto-continue after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring(duration: 0.4)) {
                showBetween = false
            }
        }
    }

    private func skipToNext() {
        let nextIndex = currentIndex + 1
        if nextIndex >= exercises.count {
            saveSession(completed: true)
        } else {
            currentIndex = nextIndex
            progress = 0
            AudioManager.playTick()
        }
    }

    private func endSessionEarly() {
        saveSession(completed: false)
    }

    private func saveSession(completed: Bool) {
        guard let userId = appState.currentUser?.id else {
            dismiss()
            return
        }

        let session = Session(
            userId: userId,
            startedAt: sessionStartedAt,
            endedAt: .now,
            sessionType: sessionType,
            totalDurationSec: totalElapsedSeconds,
            completed: completed,
            exerciseCount: completed ? exercises.count : currentIndex + 1,
            exerciseIndices: exercises.prefix(completed ? exercises.count : currentIndex + 1).map(\.index),
            accuracy: eyeTracker.isTracking ? eyeTracker.computeAccuracy() : nil
        )

        modelContext.insert(session)
        try? modelContext.save()

        stopTimer()

        // Advance course day if this was a course session
        if completed && sessionType == .course {
            advanceCourseDay()
        }

        if completed {
            AudioManager.playGong()
            resultSession = session
            showResult = true
        } else {
            dismiss()
        }
    }

    private func advanceCourseDay() {
        let descriptor = FetchDescriptor<CourseProgress>(
            predicate: #Predicate { $0.active == true }
        )
        guard let active = try? modelContext.fetch(descriptor).first else { return }
        if let course = CourseDefinition[active.courseId] {
            let nextDay = active.currentDay + 1
            if nextDay > course.durationDays {
                active.active = false // course complete
            } else {
                active.currentDay = nextDay
            }
            active.updatedAt = .now
            try? modelContext.save()
        }
    }

    // MARK: – Helpers

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    ExerciseActiveView(
        exercises: Array(ExerciseDefinition.all.prefix(3)),
        sessionType: .quick,
        courseId: nil
    )
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
