import AudioToolbox
import Foundation

/// Lightweight audio feedback using system sounds.
/// No AudioContext leak — pure system sound IDs.
enum AudioManager {
    /// Short beep for exercise transitions.
    static func playBeep() {
        AudioServicesPlaySystemSound(1057)
    }

    /// Completion chime.
    static func playGong() {
        AudioServicesPlaySystemSound(1025)
    }

    /// Subtle tick.
    static func playTick() {
        AudioServicesPlaySystemSound(1104)
    }

    /// Launch chime — clean notification tone for the brand reveal.
    static func playLaunchChime() {
        AudioServicesPlaySystemSound(1013)
    }

    // MARK: – Exercise cues
    //
    // These respect the per-user "soundCuesEnabled" toggle stored in
    // UserDefaults so they can be silenced in public places without going
    // through AppState (renderers don't need to import AppState).

    private static var cuesAllowed: Bool {
        // Default true; explicit false disables.
        (UserDefaults.standard.object(forKey: "axeo_sound_cues") as? Bool) ?? true
    }

    /// Soft chime: signal a focus-shift phase change (near↔far).
    static func playPhaseChange() {
        guard cuesAllowed else { return }
        AudioServicesPlaySystemSound(1110)
    }

    /// Halfway-through cue for guided closed-eye exercises (Palming, etc.).
    static func playMidpoint() {
        guard cuesAllowed else { return }
        AudioServicesPlaySystemSound(1117)
    }

    /// Final cue to open eyes / end exercise.
    static func playEndCue() {
        guard cuesAllowed else { return }
        AudioServicesPlaySystemSound(1025)
    }

    /// Very subtle tick used during repetitive exercises (e.g. Saccades) when
    /// the dot moves to a new position. Respects the user's sound-cues toggle.
    static func playSubtleTick() {
        guard cuesAllowed else { return }
        AudioServicesPlaySystemSound(1104)
    }
}
