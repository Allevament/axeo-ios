import SwiftUI
import UserNotifications

/// Compact single-screen session result card.
/// Exercise logo at top, stats bento, Done → straight to home.
struct SessionResultView: View {
    let session: Session
    let courseId: UUID?
    var onDone: (() -> Void)? = nil

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var showConfetti = false
    @State private var reminderSet = false
    @State private var showPaywall = false

    private var firstExercise: ExerciseDefinition? {
        session.exerciseIndices.first.flatMap { ExerciseDefinition[$0] }
    }

    var body: some View {
        ZStack {
            Color.aveoBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                // Hero: exercise icon + checkmark
                heroSection
                    .padding(.bottom, 16)

                // Stats 2×2 bento
                statsGrid
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                // Exercise chips
                exerciseChips
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                // Upgrade prompt (only for free users, after 1+ sessions)
                if !appState.isPremium && appState.freeSessionCount >= 1 {
                    UpgradePromptView(
                        context: appState.shouldShowSessionGate
                            ? .sessionGate(sessionCount: appState.freeSessionCount)
                            : .postSession(exerciseCount: session.exerciseCount)
                    ) {
                        showPaywall = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)
                }

                Spacer(minLength: 8)

                // Bottom actions
                VStack(spacing: 10) {
                    reminderButton
                    doneButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            appState.recordFreeSession()
            withAnimation(.spring(duration: 0.6, bounce: 0.35).delay(0.15)) {
                appeared = true
            }
            if courseId != nil {
                withAnimation(.easeOut(duration: 0.1).delay(0.4)) {
                    showConfetti = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation { showConfetti = false }
                }
            }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            ZStack {
                // Radial glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.aveoRetinal.opacity(0.1), Color.aveoSuccess.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 16,
                            endRadius: 60
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0.0)

                // Pulse ring
                Circle()
                    .strokeBorder(Color.aveoSuccess.opacity(0.12), lineWidth: 1.5)
                    .frame(width: 100, height: 100)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0.0)

                // Exercise icon on top of checkmark
                VStack(spacing: 4) {
                    if let ex = firstExercise {
                        Image(systemName: ex.sfSymbol)
                            .font(.system(size: 28))
                            .foregroundStyle(ex.motionType.category.color)
                    }
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.aveoSuccess)
                }
                .scaleEffect(appeared ? 1.0 : 0.3)
                .opacity(appeared ? 1.0 : 0.0)
            }

            Text("Workout Complete!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 8)

            Text("Your eyes will thank you")
                .font(.system(size: 11))
                .foregroundStyle(Color.aveoText3)
                .opacity(appeared ? 1.0 : 0.0)
        }
    }

    // MARK: – Stats Grid

    private var statsGrid: some View {
        let minutes = session.totalDurationSec / 60
        let seconds = session.totalDurationSec % 60
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

        return LazyVGrid(columns: columns, spacing: 10) {
            resultStat(
                label: NSLocalizedString("Duration", comment: ""),
                value: String(format: "%dm %ds", minutes, seconds),
                icon: "timer",
                gradient: [.aveoTeal, .aveoAccent]
            )
            resultStat(
                label: NSLocalizedString("Exercises", comment: ""),
                value: "\(session.exerciseCount)",
                icon: "eye.fill",
                gradient: [.aveoAccent, Color(hex: 0x0088CC)]
            )
            resultStat(
                label: NSLocalizedString("Focus Score", comment: ""),
                value: session.accuracy != nil ? "\(session.accuracy!)%" : "—",
                icon: "scope",
                gradient: [.aveoGold, .aveoRetinal]
            )
            resultStat(
                label: NSLocalizedString("Status", comment: ""),
                value: session.completed ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Partial", comment: ""),
                icon: "checkmark.seal.fill",
                gradient: [.aveoSuccess, Color(hex: 0x0EA47A)]
            )
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 14)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    private func resultStat(label: String, value: String, icon: String, gradient: [Color]) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Spacer()
            }

            HStack {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.aveoText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
            }

            HStack {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.aveoText3)
                Spacer()
            }
        }
        .padding(10)
        .glassCard(cornerRadius: 12, padding: 0)
    }

    // MARK: – Exercise Chips

    private var exerciseChips: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("COMPLETED")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.6)

            FlowLayout(spacing: 6) {
                ForEach(Array(session.exerciseIndices.enumerated()), id: \.offset) { _, idx in
                    if let ex = ExerciseDefinition[idx] {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(Color.aveoSuccess)
                            Text(ex.name)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color.aveoText)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background {
                            Capsule().fill(.ultraThinMaterial)
                                .overlay { Capsule().fill(Color.aveoGlass) }
                        }
                        .overlay {
                            Capsule().strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
    }

    // MARK: – 20-20-20 Reminder

    private var reminderButton: some View {
        Button {
            HapticManager.light()
            schedule2020Reminder()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: reminderSet ? "bell.badge.fill" : "bell.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(reminderSet ? Color.aveoSuccess : Color.aveoGold)
                Text(reminderSet
                     ? NSLocalizedString("Reminder Set ✓", comment: "")
                     : NSLocalizedString("Set 20-20-20 Reminder", comment: ""))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(reminderSet ? Color.aveoSuccess : Color.aveoText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 12, padding: 0)
        }
        .disabled(reminderSet)
    }

    // MARK: – Done → Home

    private var doneButton: some View {
        Button {
            HapticManager.medium()
            if let onDone {
                onDone()
            } else {
                dismiss()
            }
        } label: {
            Text("Done")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoBg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient.aveoTealGradient,
                    in: Capsule()
                )
                .shadow(color: Color.aveoTeal.opacity(0.25), radius: 12, y: 4)
        }
    }

    // MARK: – Actions

    private func schedule2020Reminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("20-20-20 Break", comment: "")
            content.body = NSLocalizedString("Look at something 20 feet away for 20 seconds. Your eyes will thank you!", comment: "")
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20 * 60, repeats: false)
            let request = UNNotificationRequest(identifier: "axeo-2020-\(UUID())", content: content, trigger: trigger)

            center.add(request)
            DispatchQueue.main.async {
                reminderSet = true
                HapticManager.success()
            }
        }
    }
}

// MARK: – Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = (0..<30).map { _ in ConfettiParticle() }
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ForEach(particles.indices, id: \.self) { i in
                let p = particles[i]
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.color)
                    .frame(width: p.size, height: p.size * 1.5)
                    .rotationEffect(.degrees(animate ? p.rotation + 360 : p.rotation))
                    .position(
                        x: p.x * geo.size.width,
                        y: animate ? geo.size.height + 50 : -50
                    )
                    .animation(
                        .easeIn(duration: p.duration)
                            .delay(p.delay),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

struct ConfettiParticle {
    let x: CGFloat = CGFloat.random(in: 0.05...0.95)
    let color: Color = [Color.aveoAccent, .aveoRetinal, .aveoGold, .aveoSuccess, .aveoData, .aveoAccent2].randomElement()!
    let size: CGFloat = CGFloat.random(in: 5...10)
    let rotation: Double = Double.random(in: 0...360)
    let duration: Double = Double.random(in: 2.0...4.0)
    let delay: Double = Double.random(in: 0...1.5)
}

#Preview {
    SessionResultView(
        session: Session(
            userId: UUID(),
            startedAt: .now.addingTimeInterval(-300),
            endedAt: .now,
            sessionType: .quick,
            totalDurationSec: 300,
            completed: true,
            exerciseCount: 5,
            exerciseIndices: [0, 1, 2, 3, 4],
            accuracy: 87
        ),
        courseId: UUID()
    )
    .preferredColorScheme(.dark)
}
