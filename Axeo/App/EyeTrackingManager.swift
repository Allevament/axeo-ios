import ARKit
import Combine
import SwiftUI

/// Manages real-time eye & face tracking via ARKit TrueDepth camera.
///
/// `@MainActor` so all @Observable state mutations run on the main thread
/// (Swift 6 strict concurrency). ARKit delivers `session(_:didUpdate:)`
/// on a background queue — the delegate method is marked `nonisolated`,
/// extracts primitive blend-shape floats (cheap, Sendable), then hops to
/// the main actor to apply them via `applyBlendShapes(...)`.
///
/// Published properties:
/// - `isTracking` — session is running
/// - `blinkCount` — total blinks detected this session
/// - `gazeOnTarget` — 0…1, fraction of time the user's gaze is roughly on-screen
/// - `leftEyeGaze` / `rightEyeGaze` — raw gaze vectors (yaw, pitch) in radians
///
/// Usage:
/// 1. Call `start()` to begin the AR session
/// 2. Read published values from SwiftUI views
/// 3. Call `stop()` when finished
/// 4. Call `computeAccuracy()` to get a 0–100 focus score
@MainActor
@Observable
final class EyeTrackingManager: NSObject {

    // MARK: – Published State

    var isTracking = false
    var isSupported: Bool { ARFaceTrackingConfiguration.isSupported }

    /// Blink detection
    var blinkCount: Int = 0
    var isBlinking = false

    /// Eye openness (0 = closed, 1 = fully open)
    var leftEyeOpenness: Float = 1
    var rightEyeOpenness: Float = 1

    /// Gaze direction (yaw, pitch) in radians — small values = looking at screen
    var leftEyeYaw: Float = 0
    var leftEyePitch: Float = 0
    var rightEyeYaw: Float = 0
    var rightEyePitch: Float = 0

    /// Focus score: fraction of samples where gaze was "on screen"
    var gazeOnTarget: Double = 1.0

    // MARK: – Private

    private var arSession: ARSession?
    private let blinkThreshold: Float = 0.4     // blend shape value below = blink
    private let gazeThreshold: Float = 0.15     // radians — ~8.5° from centre = on screen

    // Blink edge detection
    private var wasBlinking = false

    // Accuracy tracking
    private var onTargetSamples: Int = 0
    private var totalSamples: Int = 0

    // MARK: – Lifecycle

    func start() {
        guard isSupported else { return }

        // Tear down any prior session before starting a new one — prevents
        // a dangling ARSession if start() is called twice without stop()
        // (e.g. exercise transition with cvEnabled across two views).
        arSession?.pause()
        arSession = nil

        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = false // save battery

        let session = ARSession()
        session.delegate = self
        session.run(config, options: [.resetTracking, .removeExistingAnchors])

        arSession = session
        isTracking = true
        blinkCount = 0
        onTargetSamples = 0
        totalSamples = 0
        gazeOnTarget = 1.0
    }

    func stop() {
        arSession?.pause()
        arSession = nil
        isTracking = false
    }

    /// Returns a 0–100 integer accuracy score.
    func computeAccuracy() -> Int {
        guard totalSamples > 0 else { return 0 }
        return Int(Double(onTargetSamples) / Double(totalSamples) * 100)
    }

    func reset() {
        blinkCount = 0
        onTargetSamples = 0
        totalSamples = 0
        gazeOnTarget = 1.0
        wasBlinking = false
    }
}

// MARK: – ARSessionDelegate

extension EyeTrackingManager: ARSessionDelegate {

    /// ARKit delivers this callback on a background queue. We extract the
    /// blend-shape floats synchronously (they're Sendable primitives) and
    /// hop to the main actor to apply them to `@Observable` state.
    nonisolated func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        let shapes = faceAnchor.blendShapes
        let leftBlink  = shapes[.eyeBlinkLeft]?.floatValue  ?? 0
        let rightBlink = shapes[.eyeBlinkRight]?.floatValue ?? 0
        let lookInL    = shapes[.eyeLookInLeft]?.floatValue  ?? 0
        let lookOutL   = shapes[.eyeLookOutLeft]?.floatValue ?? 0
        let lookUpL    = shapes[.eyeLookUpLeft]?.floatValue  ?? 0
        let lookDownL  = shapes[.eyeLookDownLeft]?.floatValue ?? 0
        let lookInR    = shapes[.eyeLookInRight]?.floatValue  ?? 0
        let lookOutR   = shapes[.eyeLookOutRight]?.floatValue ?? 0
        let lookUpR    = shapes[.eyeLookUpRight]?.floatValue  ?? 0
        let lookDownR  = shapes[.eyeLookDownRight]?.floatValue ?? 0

        Task { @MainActor [weak self] in
            self?.applyBlendShapes(
                leftBlink: leftBlink, rightBlink: rightBlink,
                lookInL: lookInL, lookOutL: lookOutL, lookUpL: lookUpL, lookDownL: lookDownL,
                lookInR: lookInR, lookOutR: lookOutR, lookUpR: lookUpR, lookDownR: lookDownR
            )
        }
    }

    private func applyBlendShapes(
        leftBlink: Float, rightBlink: Float,
        lookInL: Float, lookOutL: Float, lookUpL: Float, lookDownL: Float,
        lookInR: Float, lookOutR: Float, lookUpR: Float, lookDownR: Float
    ) {
        // ── Eye openness ──
        leftEyeOpenness  = 1.0 - leftBlink
        rightEyeOpenness = 1.0 - rightBlink

        // ── Blink detection (edge trigger) ──
        let currentlyBlinking = leftEyeOpenness < blinkThreshold && rightEyeOpenness < blinkThreshold
        if currentlyBlinking && !wasBlinking {
            blinkCount += 1
        }
        isBlinking = currentlyBlinking
        wasBlinking = currentlyBlinking

        // ── Gaze direction ──
        leftEyeYaw    = lookOutL - lookInL    // positive = looking left
        leftEyePitch  = lookUpL - lookDownL   // positive = looking up
        rightEyeYaw   = lookOutR - lookInR
        rightEyePitch = lookUpR - lookDownR

        // ── Focus scoring ──
        let avgYaw   = (abs(leftEyeYaw) + abs(rightEyeYaw)) / 2
        let avgPitch = (abs(leftEyePitch) + abs(rightEyePitch)) / 2
        let onTarget = avgYaw < gazeThreshold && avgPitch < gazeThreshold

        totalSamples += 1
        if onTarget { onTargetSamples += 1 }

        // Running average (smooth for UI)
        if totalSamples > 0 {
            gazeOnTarget = Double(onTargetSamples) / Double(totalSamples)
        }
    }
}
