import SwiftUI
import SwiftData

@Observable
final class AppState {

    // MARK: – Current user

    var currentUser: User?
    var isPremiumBacking: Bool = UserDefaults.standard.bool(forKey: "axeo_premium")

    var isPremium: Bool {
        get { isPremiumBacking }
        set {
            isPremiumBacking = newValue
            UserDefaults.standard.set(newValue, forKey: "axeo_premium")
        }
    }
    var disclaimerBacking: Bool = UserDefaults.standard.bool(forKey: "axeo_disclaimer_v1")

    var hasSeenDisclaimer: Bool {
        get { disclaimerBacking }
        set {
            disclaimerBacking = newValue
            UserDefaults.standard.set(newValue, forKey: "axeo_disclaimer_v1")
        }
    }

    // MARK: – Appearance

    enum AppTheme: String, CaseIterable {
        case system
        case dark
        case light

        var label: String {
            switch self {
            case .system: NSLocalizedString("System", comment: "")
            case .dark:   NSLocalizedString("Dark", comment: "")
            case .light:  NSLocalizedString("Light", comment: "")
            }
        }

        var icon: String {
            switch self {
            case .system: "circle.lefthalf.filled"
            case .dark:   "moon.fill"
            case .light:  "sun.max.fill"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: nil
            case .dark:   .dark
            case .light:  .light
            }
        }
    }

    /// Stored backing value so @Observable can track mutations and
    /// trigger SwiftUI view updates without requiring an app restart.
    var themeRaw: String = UserDefaults.standard.string(forKey: "axeo_theme") ?? "system"

    var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
        set {
            themeRaw = newValue.rawValue
            UserDefaults.standard.set(newValue.rawValue, forKey: "axeo_theme")
        }
    }

    // MARK: – Onboarding

    var onboardedBacking: Bool = UserDefaults.standard.bool(forKey: "axeo_onboarded")

    var hasCompletedOnboarding: Bool {
        get { onboardedBacking }
        set {
            onboardedBacking = newValue
            UserDefaults.standard.set(newValue, forKey: "axeo_onboarded")
        }
    }

    // MARK: – Exercise audio cues

    /// When true, exercises play short chimes to signal phase transitions
    /// (focus shift, halfway, finish). Users in public places can turn this
    /// off so the app doesn't disturb others.
    var soundCuesBacking: Bool = UserDefaults.standard.object(forKey: "axeo_sound_cues") as? Bool ?? true

    var soundCuesEnabled: Bool {
        get { soundCuesBacking }
        set {
            soundCuesBacking = newValue
            UserDefaults.standard.set(newValue, forKey: "axeo_sound_cues")
        }
    }

    // MARK: – Free Session Counter (for soft paywall)

    /// Number of completed sessions in free tier.
    /// After `freeSessionLimit`, a soft paywall is shown automatically.
    static let freeSessionLimit = 3

    var freeSessionCountBacking: Int = UserDefaults.standard.integer(forKey: "axeo_free_sessions")

    var freeSessionCount: Int {
        get { freeSessionCountBacking }
        set {
            freeSessionCountBacking = newValue
            UserDefaults.standard.set(newValue, forKey: "axeo_free_sessions")
        }
    }

    /// Returns true when the user has hit the free session limit and should see a paywall.
    var shouldShowSessionGate: Bool {
        !isPremium && freeSessionCount >= Self.freeSessionLimit
    }

    /// Call after each completed session.
    func recordFreeSession() {
        guard !isPremium else { return }
        freeSessionCount += 1
    }

    // MARK: – Helpers

    /// Creates a guest user and persists it via the supplied model context.
    func createGuestUser(in context: ModelContext) {
        let guest = User(
            displayName: "Guest",
            email: "",
            goal: .prevention
        )
        context.insert(guest)
        try? context.save()
        currentUser = guest
        hasCompletedOnboarding = true
    }

    /// Loads the most-recently-created user from SwiftData on launch.
    func loadUser(from context: ModelContext) {
        let descriptor = FetchDescriptor<User>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        currentUser = try? context.fetch(descriptor).first
    }
}
