import SwiftUI
import SwiftData

struct ProgramsListView: View {
    @Environment(AppState.self) private var appState
    @Query private var courseProgresses: [CourseProgress]
    @State private var selectedCourse: CourseDefinition?
    @State private var showPaywall = false
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                activeProgramSection
                allProgramsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AmbientBackground())
        .navigationTitle("Programs")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedCourse) { course in
            ProgramDetailView(course: course)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            guard !appeared else { return }
            withAnimation(.spring(duration: 0.5)) { appeared = true }
        }
    }

    // MARK: – Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Training Programs")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
            Text("Clinically designed · Doctor-approved")
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: – Active Program

    @ViewBuilder
    private var activeProgramSection: some View {
        let activeProgresses = courseProgresses.filter(\.active)
        if !activeProgresses.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("IN PROGRESS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.aveoText3)
                    .kerning(0.8)

                ForEach(activeProgresses, id: \.courseId) { progress in
                    if let course = CourseDefinition[progress.courseId] {
                        activeCourseCard(course: course, progress: progress)
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)
            .animation(.spring(duration: 0.5).delay(0.06), value: appeared)
        }
    }

    private func activeCourseCard(course: CourseDefinition, progress: CourseProgress) -> some View {
        let pct = Double(progress.currentDay) / Double(course.durationDays)

        return Button {
            HapticManager.selection()
            selectedCourse = course
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(course.color.opacity(0.15), lineWidth: 2.5)
                            .frame(width: 42, height: 42)
                        Circle()
                            .trim(from: 0, to: pct)
                            .stroke(course.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .frame(width: 42, height: 42)
                            .rotationEffect(.degrees(-90))
                        Image(systemName: course.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(course.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(course.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.aveoText)
                        Text(String(format: NSLocalizedString("Day %d of %d", comment: ""), progress.currentDay, course.durationDays))
                            .font(.system(size: 11))
                            .foregroundStyle(Color.aveoText2)
                    }

                    Spacer()

                    Text("\(Int(pct * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(course.color)
                }

                HStack {
                    Spacer()
                    Label("Continue Training", systemImage: "play.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(course.color)
                    Spacer()
                }
                .padding(.vertical, 8)
                .background {
                    Capsule().fill(course.color.opacity(0.1))
                }
            }
            .padding(14)
            .glassCard(cornerRadius: 18, padding: 0)
        }
        .buttonStyle(.pressScale)
    }

    // MARK: – All Programs

    private var allProgramsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ALL PROGRAMS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.aveoText3)
                .kerning(0.8)

            ForEach(Array(CourseDefinition.all.enumerated()), id: \.element.id) { idx, course in
                expandedCourseCard(course, index: idx)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(.spring(duration: 0.5).delay(0.12), value: appeared)
    }

    private func expandedCourseCard(_ course: CourseDefinition, index: Int) -> some View {
        let hasProgress = courseProgresses.contains { $0.courseId == course.id }
        let isFeatured = index == 0

        let isLocked = !course.isFree && !appState.isPremium

        return Button {
            HapticManager.selection()
            if isLocked {
                showPaywall = true
            } else {
                selectedCourse = course
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Top row: icon + name + chevron
                HStack(spacing: 10) {
                    Image(systemName: course.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isLocked ? course.color.opacity(0.4) : course.color)
                        .frame(width: 40, height: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(course.color.opacity(isLocked ? 0.06 : 0.12))
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 5) {
                            Text(course.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(isLocked ? Color.aveoText3 : Color.aveoText)

                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.aveoGold)
                            } else if hasProgress {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.aveoSuccess)
                            }
                        }

                        Text(course.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(isLocked ? Color.aveoText3.opacity(0.6) : Color.aveoText2)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    if isLocked {
                        Text("PRO")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.aveoGold))
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.aveoText3)
                    }
                }

                // Description - full text, no truncation
                Text(course.description)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.aveoText3)
                    .fixedSize(horizontal: false, vertical: true)

                // Badges row
                HStack(spacing: 6) {
                    badge(String(format: NSLocalizedString("%d days", comment: ""), course.durationDays), icon: "calendar", color: course.color)
                    ForEach(course.badges, id: \.self) { b in
                        badge(b, icon: "stethoscope", color: .aveoTeal)
                    }
                }
            }
            .padding(14)
            .glassCard(cornerRadius: 16, padding: 0)
            .overlay(alignment: .topLeading) {
                // Difficulty level badge — upper-left corner
                Text(course.difficulty.label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(course.difficulty.color))
                    .offset(x: 8, y: -6)
            }
            .overlay(alignment: .topTrailing) {
                if isLocked {
                    Text("Premium")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.aveoGold))
                        .offset(x: -8, y: -6)
                } else if isFeatured {
                    Text("Featured")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.aveoRetinal))
                        .offset(x: -8, y: -6)
                } else if !hasProgress {
                    Text("Start Free →")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.aveoSuccess))
                        .offset(x: -8, y: -6)
                }
            }
        }
        .buttonStyle(.pressScale)
    }

    private func badge(_ text: String, icon: String? = nil, color: Color) -> some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 8))
            }
            Text(text)
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background {
            Capsule().fill(color.opacity(0.08))
        }
    }
}

// MARK: – Identifiable Conformance for nav

extension CourseDefinition: Hashable {
    static func == (lhs: CourseDefinition, rhs: CourseDefinition) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

#Preview {
    NavigationStack {
        ProgramsListView()
    }
    .environment(AppState())
    .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
    .preferredColorScheme(.dark)
}
