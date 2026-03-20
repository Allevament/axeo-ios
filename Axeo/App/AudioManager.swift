import AudioToolbox

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
}
