import AVFoundation
import Foundation

/// Plays looped ambient music during relaxation / closed-eye exercises, plus
/// a soft completion cue that can replace the harsh system gong for those.
///
/// All output respects the per-user "Ambient Music" toggle in
/// UserDefaults (`axeo_ambient_music`, default true) so it can be silenced
/// from the in-exercise mute button or Profile preferences.
enum AmbientAudioPlayer {

    /// Named tracks bundled with the app. Matches files in Axeo/Resources/Audio.
    enum Track: String {
        case deepDrone = "deep-drone"
        case softBreath = "soft-breath"
        case distantRain = "distant-rain"
        case endSoft = "end-soft"
    }

    // MARK: – Settings

    static var musicEnabled: Bool {
        get { (UserDefaults.standard.object(forKey: "axeo_ambient_music") as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "axeo_ambient_music") }
    }

    // MARK: – Loop player

    private static var loopPlayer: AVAudioPlayer?

    /// Start looping the given track. Crossfades from current track if one is
    /// already playing. No-op when ambient music is disabled.
    static func startLoop(_ track: Track, fadeIn: TimeInterval = 1.5) {
        guard musicEnabled else { return }
        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "m4a") else {
            return // File not bundled — silently skip
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            return
        }

        // Stop any prior loop quickly so a new exercise starts clean.
        loopPlayer?.stop()

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = 0
            p.prepareToPlay()
            p.play()
            p.setVolume(1.0, fadeDuration: fadeIn)
            loopPlayer = p
        } catch {
            return
        }
    }

    /// Fade out and stop the loop. Safe to call when nothing is playing.
    static func stopLoop(fadeOut: TimeInterval = 1.0) {
        guard let p = loopPlayer else { return }
        p.setVolume(0, fadeDuration: fadeOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut + 0.05) {
            if p === loopPlayer {
                p.stop()
                loopPlayer = nil
            }
        }
    }

    // MARK: – Soft end cue

    private static var cuePlayer: AVAudioPlayer?

    /// Plays the soft completion bell (overrides the harsh system gong for
    /// relaxation / closed-eye exercises).
    static func playSoftEnd() {
        guard musicEnabled else { return }
        guard let url = Bundle.main.url(forResource: Track.endSoft.rawValue, withExtension: "m4a") else {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
            let p = try AVAudioPlayer(contentsOf: url)
            p.volume = 1.0
            p.prepareToPlay()
            p.play()
            cuePlayer = p
        } catch {
            return
        }
    }
}
