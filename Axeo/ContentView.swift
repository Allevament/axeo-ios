import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showLaunch = true

    var body: some View {
        ZStack {
            Group {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .opacity(showLaunch ? 0 : 1)

            if showLaunch {
                AXEOLaunchView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLaunch = false
                    }
                }
                .transition(.opacity)
            }
        }
        .task {
            appState.loadUser(from: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(for: [User.self, Session.self, VisionTestResult.self, CourseProgress.self], inMemory: true)
}
