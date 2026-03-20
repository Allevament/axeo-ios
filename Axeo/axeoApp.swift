import SwiftUI
import SwiftData

@main
struct axeoApp: App {
    @State private var appState = AppState()
    @State private var storeManager = StoreManager()

    init() {
        HapticManager.prepare()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(storeManager)
                .preferredColorScheme(appState.theme.colorScheme)
                .task {
                    await storeManager.loadProducts()
                    await storeManager.restorePurchases()
                    // Always reconcile: StoreKit is the source of truth,
                    // UserDefaults is only a cache for instant UI on launch.
                    let verified = storeManager.isPremium
                    if appState.isPremium != verified {
                        print("[App] Premium cache mismatch — cached=\(appState.isPremium), actual=\(verified). Correcting.")
                        appState.isPremium = verified
                    }
                    print("[App] Premium status: \(appState.isPremium)")
                }
                .task {
                    // listenForTransactions() is an infinite async sequence —
                    // never put code after it (it would be dead code).
                    // Instead, StoreManager now calls the onChange callback
                    // each time a transaction arrives.
                    let state = appState
                    await storeManager.listenForTransactions { isPremium in
                        Task { @MainActor in
                            state.isPremium = isPremium
                            print("[App] Premium status updated via transaction: \(isPremium)")
                        }
                    }
                }
        }
        .modelContainer(for: [
            User.self,
            Session.self,
            VisionTestResult.self,
            CourseProgress.self
        ])
    }
}
