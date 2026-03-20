import ARKit
import Combine
import SwiftUI

/// Manages real-time eye & face tracking via ARKit TrueDepth camera.
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

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        let blendShapes = faceAnchor.blendShapes

        // ── Eye openness ──
        if let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue {
            leftEyeOpenness = 1.0 - leftBlink
        }
        if let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue {
            rightEyeOpenness = 1.0 - rightBlink
        }

        // ── Blink detection (edge trigger) ──
        let currentlyBlinking = leftEyeOpenness < blinkThreshold && rightEyeOpenness < blinkThreshold
        if currentlyBlinking && !wasBlinking {
            blinkCount += 1
        }
        isBlinking = currentlyBlinking
        wasBlinking = currentlyBlinking

        // ── Gaze direction ──
        if let lookInL  = blendShapes[.eyeLookInLeft]?.floatValue,
           let lookOutL = blendShapes[.eyeLookOutLeft]?.floatValue,
           let lookUpL  = blendShapes[.eyeLookUpLeft]?.floatValue,
           let lookDownL = blendShapes[.eyeLookDownLeft]?.floatValue {
            leftEyeYaw   = lookOutL - lookInL     // positive = looking left
            leftEyePitch  = lookUpL - lookDownL    // positive = looking up
        }
        if let lookInR  = blendShapes[.eyeLookInRight]?.floatValue,
           let lookOutR = blendShapes[.eyeLookOutRight]?.floatValue,
           let lookUpR  = blendShapes[.eyeLookUpRight]?.floatValue,
           let lookDownR = blendShapes[.eyeLookDownRight]?.floatValue {
            rightEyeYaw  = lookOutR - lookInR
            rightEyePitch = lookUpR - lookDownR
        }

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
