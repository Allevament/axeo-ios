import SwiftUI

struct ExerciseLibraryView: View {
    @Environment(AppState.self) private var appState
    @State private var expandedCategory: ExerciseCategoryType?
    @State private var showPaywall = false
    @State private var selectedExercise: ExerciseDefinition?
    @State private var appeared = false

    private var isPremium: Bool { appState.isPremium }

    // MARK: – Body

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                statsHeader
                categoryGrid
                medicalFooter
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AmbientBackground())
        .navigationTitle("Exercise Library")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            guard !appeared else { return }
            withAnimation(.spring(duration: 0.5)) { appeared = true }
        }
    }

    // MARK: – Stats Header

    private var statsHeader: some View {
        HStack(spacing: 10) {
            statPill(value: "\(ExerciseDefinition.all.count)", label: NSLocalizedString("exercises", comment: ""))
            statPill(value: "\(ExerciseCategoryType.allCases.count)", label: NSLocalizedString("categories", comment: ""))
            statPill(value: "~\(totalMinutes)", label: NSLocalizedString("min total", comment: ""))
        }
        .padding(.top, 4)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.aveoTeal)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 14, padding: 0)
    }

    private var totalMinutes: Int {
        ExerciseDefinition.all.reduce(0) { $0 + $1.duration } / 60
    }

    // MARK: – Category Grid (3×2 Bento)

    private var categoryGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(ExerciseCategoryType.allCases.enumerated()), id: \.element.id) { idx, category in
                categoryBentoCard(category, index: idx)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(.spring(duration: 0.5).delay(0.08), value: appeared)
    }

    @ViewBuilder
    private func categoryBentoCard(_ category: ExerciseCategoryType, index: Int) -> some View {
        let isExpanded = expandedCategory == category

        VStack(spacing: 0) {
            // Category card – always visible
            Button {
                HapticManager.light()
                withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                    expandedCategory = isExpanded ? nil : category
                }
            } label: {
                VStack(spacing: 8) {
                    // Icon + count
                    HStack {
                        Image(systemName: category.sfSymbol)
                            .font(.system(size: 20))
                            .foregroundStyle(category.color)
                        Spacer()
                        Text("\(category.exercises.count)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.aveoText2)
                    }

                    // Name
                    HStack {
                        Text(category.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.aveoText)
                            .lineLimit(1)
                        Spacer()
                    }

                    // Subtitle
                    HStack {
                        Text(category.subtitle)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.aveoText3)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }

                    // Duration badge
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 8))
                            Text("~\(category.totalDuration / 60)m")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundStyle(category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background {
                            Capsule().fill(category.color.opacity(0.08))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.aveoText3)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .padding(12)
            }
            .buttonStyle(.pressScale)

            // Expanded exercise list
            if isExpanded {
                VStack(spacing: 0) {
                    Divider().overlay(Color.aveoBorder)
                        .padding(.horizontal, 12)

                    ForEach(category.exercises) { exercise in
                        exerciseRow(exercise, categoryColor: category.color)
                        if exercise.id != category.exercises.last?.id {
                            Divider().overlay(Color.aveoBorder)
                                .padding(.leading, 48)
                        }
                    }
                }
                .padding(.bottom, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassCard(cornerRadius: 16, padding: 0)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isExpanded ? category.color.opacity(0.3) : Color.clear,
                    lineWidth: 0.5
                )
        }
    }

    // MARK: – Exercise Row

    @ViewBuilder
    private func exerciseRow(_ exercise: ExerciseDefinition, categoryColor: Color) -> some View {
        let isLocked = exercise.index >= ExerciseDefinition.premiumThreshold && !isPremium

        Button {
            HapticManager.selection()
            if isLocked {
                showPaywall = true
            } else {
                selectedExercise = exercise
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: exercise.sfSymbol)
                    .font(.system(size: 12))
                    .foregroundStyle(categoryColor)
                    .frame(width: 24, height: 24)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(categoryColor.opacity(0.1))
                    }

                VStack(alignment: .leading, spacing: 1) {
                    Text(exercise.name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.aveoText)
                        .lineLimit(1)

                    Text("\(exercise.duration)s")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.aveoTeal)
                }

                Spacer(minLength: 4)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.aveoGold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .buttonStyle(.pressScale)
    }

    // MARK: – Medical Footer

    private var medicalFooter: some View {
        Text("Based on AAO Clinical Guidelines & COVD Standards")
            .font(.system(size: 10))
            .foregroundStyle(Color.aveoText3)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }
}

#Preview {
    NavigationStack {
        ExerciseLibraryView()
    }
    .environment(AppState())
    .preferredColorScheme(.dark)
}
