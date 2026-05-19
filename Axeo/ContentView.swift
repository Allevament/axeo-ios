import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var showLaunch = true

    /// Whether the mandatory Health Disclaimer must be shown right now.
    /// Gated on `hasChosen` so the disclaimer appears AFTER the user has
    /// picked a language — that way the disclaimer text renders in the
    /// chosen locale, not the system default.
    private var needsDisclaimer: Bool {
        !showLaunch && !appState.hasSeenDisclaimer && LocalizationManager.shared.hasChosen
    }

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
        // Mandatory disclaimer — blocks all app interaction until acknowledged.
        .sheet(isPresented: .constant(needsDisclaimer)) {
            DisclaimerSheet()
                .environment(appState)
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
