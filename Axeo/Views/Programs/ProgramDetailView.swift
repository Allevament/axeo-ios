import SwiftUI
import SwiftData

struct ProgramDetailView: View {
    let course: CourseDefinition

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var courseProgresses: [CourseProgress]
    @State private var showActiveSession = false
    @State private var activeDayPlan: CourseDefinition.DayPlan?

    private var progress: CourseProgress? {
        courseProgresses.first { $0.courseId == course.id }
    }

    private var currentDay: Int {
        progress?.currentDay ?? 1
    }

    private var isEnrolled: Bool {
        progress?.active == true
    }

    @State private var sectionsAppeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroSection
                statsRow
                if isEnrolled { todaySection }
                dayPlanList
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AmbientBackground())
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(duration: 0.5)) { sectionsAppeared = true }
        }
        .fullScreenCover(isPresented: $showActiveSession) {
            if let dayPlan = activeDayPlan {
                ExerciseActiveView(
                    exercises: dayPlan.exercises,
                    sessionType: .course,
                    courseId: UUID(uuidString: course.id) ?? UUID()
                )
            }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        let pct = isEnrolled ? Double(currentDay - 1) / Double(course.durationDays) : 0

        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(course.color.opacity(0.12))
                    .frame(width: 72, height: 72)

                if isEnrolled {
                    Circle()
                        .stroke(course.color.opacity(0.15), lineWidth: 2.5)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: pct)
                        .stroke(course.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: course.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(course.color)
            }

            Text(course.name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(course.description)
                .font(.system(size: 12))
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                // Difficulty badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(course.difficulty.color)
                        .frame(width: 6, height: 6)
                    Text(course.difficulty.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(course.difficulty.color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule().fill(.ultraThinMaterial)
                        .overlay { Capsule().fill(course.difficulty.color.opacity(0.08)) }
                }
                .overlay {
                    Capsule().strokeBorder(course.difficulty.color.opacity(0.15), lineWidth: 0.5)
                }

                // Social proof
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.aveoTeal)
                    Text("Improved focus after Week 2")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.aveoText3)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule().fill(.ultraThinMaterial)
                        .overlay { Capsule().fill(Color.aveoTeal.opacity(0.06)) }
                }
            }
        }
        .padding(.top, 8)
        .opacity(sectionsAppeared ? 1 : 0)
        .offset(y: sectionsAppeared ? 0 : 12)
    }

    // MARK: – Stats Row

    private var statsRow: some View {
        HStack(spacing: 8) {
            statItem(value: "\(course.durationDays)", label: NSLocalizedString("Days", comment: ""))
            statItem(value: "\(course.dailyPlan.filter { !$0.restDay }.count)", label: NSLocalizedString("Workouts", comment: ""))
            statItem(value: "\(totalExerciseCount)", label: NSLocalizedString("Exercises", comment: ""))
        }
        .opacity(sectionsAppeared ? 1 : 0)
        .offset(y: sectionsAppeared ? 0 : 12)
        .animation(.spring(duration: 0.5).delay(0.06), value: sectionsAppeared)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(course.color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 14, padding: 0)
    }

    private var totalExerciseCount: Int {
        course.dailyPlan.reduce(0) { $0 + $1.exerciseIndices.count }
    }

    // MARK: – Today's Workout

    @ViewBuilder
    private var todaySection: some View {
        if let todayPlan = course.dailyPlan.first(where: { $0.day == currentDay }) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TODAY'S PLAN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.aveoText3)
                        .kerning(0.8)
                    Text("Daily structured eye routine")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.aveoText3.opacity(0.7))
                        .lineLimit(1)
                }

                if todayPlan.restDay {
                    HStack(spacing: 10) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.aveoSuccess)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Rest Day")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.aveoText)
                            Text("Your eyes need recovery too!")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.aveoText3)
                                .lineLimit(1)
                        }
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 14, padding: 0)
                } else {
                    VStack(spacing: 10) {
                        ForEach(todayPlan.exercises) { ex in
                            HStack(spacing: 8) {
                                Image(systemName: ex.sfSymbol)
                                    .font(.system(size: 13))
                                    .foregroundStyle(ex.motionType.category.color)
                                    .frame(width: 28, height: 28)
                                    .background {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(ex.motionType.category.color.opacity(0.1))
                                    }
                                Text(ex.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.aveoText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                Spacer()
                                Text("\(ex.duration)s")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(Color.aveoText3)
                            }
                        }

                        Button {
                            HapticManager.medium()
                            activeDayPlan = todayPlan
                            showActiveSession = true
                        } label: {
                            Label(String(format: NSLocalizedString("Start Day %d", comment: ""), currentDay), systemImage: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.aveoBg)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [course.color, course.color.opacity(0.7)],
                                        startPoint: .leading, endPoint: .trailing
                                    ),
                                    in: Capsule()
                                )
                                .shadow(color: course.color.opacity(0.3), radius: 10, y: 3)
                        }
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 14, padding: 0)
                }
            }
            .opacity(sectionsAppeared ? 1 : 0)
            .offset(y: sectionsAppeared ? 0 : 12)
            .animation(.spring(duration: 0.5).delay(0.12), value: sectionsAppeared)
        }
    }

    // MARK: – Day Plan List

    private var dayPlanList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FULL SCHEDULE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            if !isEnrolled {
                enrollButton
            }

            if isEnrolled {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.aveoText3.opacity(0.12))
                            .frame(height: 4)
                        Capsule()
                            .fill(course.color)
                            .frame(
                                width: geo.size.width * CGFloat(currentDay - 1) / CGFloat(course.durationDays),
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
            }

            ForEach(course.dailyPlan) { day in
                dayRow(day)
            }
        }
        .opacity(sectionsAppeared ? 1 : 0)
        .offset(y: sectionsAppeared ? 0 : 12)
        .animation(.spring(duration: 0.5).delay(0.18), value: sectionsAppeared)
    }

    private func dayRow(_ dayPlan: CourseDefinition.DayPlan) -> some View {
        let isPast = isEnrolled && dayPlan.day < currentDay
        let isCurrent = isEnrolled && dayPlan.day == currentDay
        let isFuture = !isEnrolled || dayPlan.day > currentDay
        let isGraduation = dayPlan.title == NSLocalizedString("Graduation Day", comment: "")

        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        isPast ? Color.aveoSuccess :
                        isCurrent ? course.color.opacity(0.2) :
                        Color.aveoText3.opacity(0.1)
                    )
                    .frame(width: 28, height: 28)
                    .shadow(color: isPast ? Color.aveoSuccess.opacity(0.4) : .clear, radius: 4)

                if isPast {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                } else if isGraduation {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(isCurrent ? course.color : Color.aveoText3)
                } else if dayPlan.restDay {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(isCurrent ? Color.aveoSuccess : Color.aveoText3)
                } else {
                    Text("\(dayPlan.day)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(isCurrent ? course.color : Color.aveoText3)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(dayPlan.restDay ? NSLocalizedString("Rest Day", comment: "") : dayPlan.title)
                    .font(.system(size: 12, weight: isCurrent || isGraduation ? .semibold : .regular))
                    .foregroundStyle(isFuture && !isCurrent ? Color.aveoText3 : Color.aveoText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                if !dayPlan.restDay {
                    Text(String(format: NSLocalizedString("%d exercises · ~%d min", comment: ""), dayPlan.exerciseIndices.count, max(1, dayPlan.estimatedMinutes)))
                        .font(.system(size: 10))
                        .foregroundStyle(Color.aveoText3)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isCurrent && !dayPlan.restDay {
                Button {
                    HapticManager.medium()
                    activeDayPlan = dayPlan
                    showActiveSession = true
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(course.color)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(isFuture && !isCurrent ? 0.5 : 1.0)
    }

    // MARK: – Enroll

    private var enrollButton: some View {
        Button {
            HapticManager.medium()
            enroll()
        } label: {
            Label("Start Program", systemImage: "play.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.aveoBg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [course.color, course.color.opacity(0.7)],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: course.color.opacity(0.3), radius: 10, y: 3)
        }
    }

    private func enroll() {
        guard let userId = appState.currentUser?.id else { return }

        // Deactivate other courses
        for cp in courseProgresses where cp.active {
            cp.active = false
        }

        let newProgress = CourseProgress(
            courseId: course.id,
            userId: userId,
            currentDay: 1,
            active: true
        )
        modelContext.insert(newProgress)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(course: .screenWarrior)
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
