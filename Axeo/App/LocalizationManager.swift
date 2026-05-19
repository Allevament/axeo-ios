import Foundation
import SwiftUI

/// Runtime language switching without app restart.
///
/// Strategy:
/// 1. Swizzle `Bundle.main` to look up strings in a per-language `.lproj` bundle.
/// 2. Expose `currentLocale` as observable; attach it via `.environment(\.locale, …)` and
///    force a tree re-render with `.id(currentLocale.identifier)` on the root view.
/// 3. Persist the choice in `AppleLanguages` so iOS picks it up on next launch too.
@MainActor
@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    static let supportedCodes: [String] = ["en", "ru", "kk", "es"]
    private static let appleLanguagesKey = "AppleLanguages"
    private static let chosenKey = "axeo_language_chosen"

    private(set) var currentLocale: Locale
    /// True once the user has explicitly chosen a language via the picker.
    /// Observable so ContentView can gate the Health Disclaimer on it.
    private(set) var hasChosen: Bool

    private init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.appleLanguagesKey)?.first
        let device = Locale.preferredLanguages.first
        let raw = stored ?? device ?? "en"
        let normalized = Self.normalize(raw)
        self.currentLocale = Locale(identifier: normalized)
        self.hasChosen = UserDefaults.standard.bool(forKey: Self.chosenKey)
        Bundle.applyAxeoLanguage(normalized)
    }

    static func normalize(_ code: String) -> String {
        let base = code.components(separatedBy: "-").first ?? code
        return supportedCodes.contains(base) ? base : "en"
    }

    func setLanguage(_ code: String) {
        let normalized = Self.normalize(code)
        UserDefaults.standard.set([normalized], forKey: Self.appleLanguagesKey)
        UserDefaults.standard.set(true, forKey: Self.chosenKey)
        Bundle.applyAxeoLanguage(normalized)
        currentLocale = Locale(identifier: normalized)
        hasChosen = true
    }
}

// MARK: – Bundle swizzle

private var axeoBundleKey: UInt8 = 0

private final class AxeoL10nBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let override = objc_getAssociatedObject(self, &axeoBundleKey) as? Bundle {
            return override.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    private static let axeoSwizzleOnce: Void = {
        object_setClass(Bundle.main, AxeoL10nBundle.self)
    }()

    static func applyAxeoLanguage(_ code: String) {
        _ = axeoSwizzleOnce
        let lproj = Bundle.main.path(forResource: code, ofType: "lproj")
            .flatMap(Bundle.init(path:))
        objc_setAssociatedObject(Bundle.main, &axeoBundleKey, lproj, .OBJC_ASSOCIATION_RETAIN)
    }
}
