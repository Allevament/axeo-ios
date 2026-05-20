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
        /// Unified relaxation ambient: soft C-E-G arpeggio with long reverb,
        /// used uniformly across all 4 relaxation exercises.
        case gentlePiano = "gentle-piano"
        case endSoft = "end-soft"
    }

    // MARK: – Settings

    static var musicEnabled: Bool {
        get { (UserDefaults.standard.object(forKey: "axeo_ambient_music") as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "axeo_ambient_music") }
    }

    // MARK: – Loop player

    private static var loopPlayer: AVAudioPlayer?
    /// Most recent track requested by a renderer's `onAppear`. Persists across
    /// mute/unmute so `resumeLoopIfPossible()` can restart the right track when
    /// the user re-enables sound mid-exercise.
    private static var lastTrack: Track?

    /// Start looping the given track. Crossfades from current track if one is
    /// already playing. No-op when ambient music is disabled, but the requested
    /// track is still remembered so a later resume picks it up.
    static func startLoop(_ track: Track, fadeIn: TimeInterval = 1.5) {
        lastTrack = track
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
    /// Intentionally does NOT clear `lastTrack` — a follow-up
    /// `resumeLoopIfPossible()` (e.g. from the mute toggle) should be able
    /// to restart the same track. New exercises overwrite `lastTrack` via
    /// their own `startLoop` call.
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

    /// Re-engage the most recently requested ambient loop. Used by the
    /// in-exercise mute toggle: when the user re-enables sound, this restarts
    /// the loop for the exercise currently on screen — no need to leave and
    /// re-enter the exercise.
    static func resumeLoopIfPossible() {
        guard musicEnabled, let track = lastTrack else { return }
        startLoop(track)
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

    /// Universal end-of-exercise cue. Stops any active ambient loop and
    /// plays the soft end bell using `.playback` category so it bypasses
    /// the iPhone Silent switch — call after EVERY exercise completion
    /// (relaxation or active). Always plays regardless of the
    /// `musicEnabled` toggle: this is a UX cue, not background music.
    static func playEndOfExerciseCue() {
        guard let url = Bundle.main.url(forResource: Track.endSoft.rawValue, withExtension: "m4a") else {
            return
        }
        loopPlayer?.stop()
        loopPlayer = nil
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
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
