import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases) { tab in
                tab.destination
                    .tabItem {
                        tab.label
                    }
                    .tag(tab)
            }
        }
        .tint(Color.aveoAccent)
        .onChange(of: selectedTab) { _, _ in
            HapticManager.light()
        }
    }
}

// MARK: – Tab Definition

extension MainTabView {
    enum Tab: String, CaseIterable, Identifiable {
        case home
        case exercises
        case programs
        case screening
        case progress

        var id: String { rawValue }

        var title: String {
            switch self {
            case .home:       NSLocalizedString("Home", comment: "")
            case .exercises:  NSLocalizedString("Exercises", comment: "")
            case .programs:   NSLocalizedString("Programs", comment: "")
            case .screening:  NSLocalizedString("Screening", comment: "")
            case .progress:   NSLocalizedString("Progress", comment: "")
            }
        }

        /// Brand icon for this tab, nil falls back to SF Symbol.
        var brandIcon: BrandIcon.Icon? {
            switch self {
            case .home:       .duochrome
            case .exercises:  .tumblingE
            case .programs:   nil
            case .screening:  .astigmatismDial
            case .progress:   .amslerGrid
            }
        }

        var sfSymbol: String {
            switch self {
            case .home:       "house.fill"
            case .exercises:  "eye.fill"
            case .programs:   "book.fill"
            case .screening:  "tablecells"
            case .progress:   "chart.bar.fill"
            }
        }

        @ViewBuilder
        var label: some View {
            if let brandIcon {
                Label {
                    Text(title)
                } icon: {
                    BrandIcon.tabImage(for: brandIcon, size: 22)
                }
            } else {
                Label(title, systemImage: sfSymbol)
            }
        }

        @ViewBuilder
        var destination: some View {
            switch self {
            case .home:
                NavigationStack {
                    HomeView()
                }
            case .exercises:
                NavigationStack {
                    ExerciseLibraryView()
                }
            case .programs:
                NavigationStack {
                    ProgramsListView()
                }
            case .screening:
                NavigationStack {
                    ScreeningListView()
                }
            case .progress:
                NavigationStack {
                    ProgressDashboardView()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
