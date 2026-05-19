import Foundation

// MARK: – Motion Type

enum MotionType: String, Codable, CaseIterable, Identifiable {
    case focus
    case eight
    case palm
    case fixate
    case blink
    case mark
    case converge
    case square
    case lines
    case warmth
    case stereo
    case fusion
    case breath
    case rule20
    case lidmassage
    case lidgym
    case tearfilm

    var id: String { rawValue }

    /// Which broad category this motion belongs to.
    var category: ExerciseCategoryType {
        switch self {
        case .focus, .mark:                          return .accommodation
        case .eight, .fixate, .square, .lines:       return .eyeMovement
        case .palm, .blink, .warmth:                 return .relaxation
        case .converge, .stereo, .fusion:            return .binocular
        case .breath, .rule20:                       return .breathing
        case .lidmassage, .lidgym, .tearfilm:        return .dryEyeRelief
        }
    }
}

// MARK: – Exercise Definition

struct ExerciseDefinition: Identifiable, Hashable {
    let index: Int
    let name: String
    let duration: Int            // seconds
    let motionType: MotionType
    let hint: String
    let cvEnabled: Bool          // has focus-score tracking
    let indications: String
    let sfSymbol: String

    var id: Int { index }

    /// Steps shown on the detail screen (derived from hint).
    var steps: [String] {
        ExerciseDefinition.stepsMap[index] ?? hint.components(separatedBy: ". ").filter { !$0.isEmpty }
    }
}

// MARK: – Full Catalog (17 exercises)

extension ExerciseDefinition {
    static let all: [ExerciseDefinition] = [
        // 0 – Accommodation
        ExerciseDefinition(
            index: 0, name: NSLocalizedString("Focus Shift", comment: ""), duration: 60, motionType: .focus,
            hint: NSLocalizedString("Hold the phone at arm's length. Focus on the dot when it's large, then look at a distant object across the room when the dot shrinks. A soft chime cues each switch. Keep your head still.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A common eye-care routine for people who spend long hours at a screen. Gives your eyes a structured break from near focus.", comment: ""),
            sfSymbol: "scope"
        ),
        // 1 – Eye Movement
        ExerciseDefinition(
            index: 1, name: NSLocalizedString("Figure Eight", comment: ""), duration: 60, motionType: .eight,
            hint: NSLocalizedString("Follow the moving dot along the figure-eight path with your eyes only. The direction reverses automatically at the halfway mark — an arrow shows which way the dot is going. Keep smooth, continuous movement.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A flexibility routine for eye movement and coordination.", comment: ""),
            sfSymbol: "infinity"
        ),
        // 2 – Relaxation
        ExerciseDefinition(
            index: 2, name: NSLocalizedString("Palming", comment: ""), duration: 90, motionType: .palm,
            hint: NSLocalizedString("Rub your palms together until warm, then gently cup them over your closed eyes. No pressure on the eyeballs. Audio cues will signal start, halfway, and the end — you don't need to watch the timer.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("A relaxation routine for tired eyes after long screen sessions.", comment: ""),
            sfSymbol: "hand.raised.fill"
        ),
        // 3 – Eye Movement
        ExerciseDefinition(
            index: 3, name: NSLocalizedString("Saccades", comment: ""), duration: 45, motionType: .fixate,
            hint: NSLocalizedString("A dot lights up in one of 9 positions. Snap your gaze to it as soon as it appears and hold until it moves to the next position. Keep your head still; only the eyes move.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A practice routine for quick, accurate eye movements during reading.", comment: ""),
            sfSymbol: "circle.grid.3x3.fill"
        ),
        // 4 – Relaxation
        ExerciseDefinition(
            index: 4, name: NSLocalizedString("Blinking", comment: ""), duration: 45, motionType: .blink,
            hint: NSLocalizedString("Look straight ahead, face relaxed. Slowly close eyelids fully — no squinting. Hold 1 second. Open slowly. Repeat every 5 seconds.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Encourages natural blinking, which tends to slow down during screen use.", comment: ""),
            sfSymbol: "eye.slash.fill"
        ),
        // 5 – Accommodation
        ExerciseDefinition(
            index: 5, name: NSLocalizedString("Window Dot", comment: ""), duration: 100, motionType: .mark,
            hint: NSLocalizedString("Hold the phone at arm's length. Focus on the dot on the screen while it's bright, then shift your gaze to the most distant object you can see (out a window if possible) when the scenery appears. A soft chime cues each switch.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A classic eye-care routine for focusing flexibility between near and far.", comment: ""),
            sfSymbol: "dot.circle.and.hand.point.up.left.fill"
        ),
        // 6 – Binocular (PREMIUM)
        ExerciseDefinition(
            index: 6, name: NSLocalizedString("Convergence", comment: ""), duration: 80, motionType: .converge,
            hint: NSLocalizedString("Hold phone at arm's length, focus on the center dot. Slowly bring it toward your nose, keeping the dot single and clear. When it doubles, move back out. — Skip this routine if you have strabismus, recent eye surgery, or any binocular-vision condition without your eye-care professional's approval.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A coordination routine for eye teaming while reading at close range.", comment: ""),
            sfSymbol: "arrow.triangle.merge"
        ),
        // 7 – Eye Movement (PREMIUM)
        ExerciseDefinition(
            index: 7, name: NSLocalizedString("Square Tracing", comment: ""), duration: 64, motionType: .square,
            hint: NSLocalizedString("Follow the dot as it traces a square with your eyes. After each lap the dot automatically reverses direction — an arrow on screen always shows the current direction. Head still, only the eyes move.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A balanced movement routine across all gaze directions.", comment: ""),
            sfSymbol: "square.dashed"
        ),
        // 8 – Eye Movement (PREMIUM)
        ExerciseDefinition(
            index: 8, name: NSLocalizedString("Vertical & Horizontal", comment: ""), duration: 60, motionType: .lines,
            hint: NSLocalizedString("Follow the dot with your eyes. It moves up and down for the first half, then switches to left and right — the dot naturally pauses at each end position. Head still throughout.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("A range-of-motion routine for the four cardinal gaze directions.", comment: ""),
            sfSymbol: "arrow.up.and.down.and.arrow.left.and.right"
        ),
        // 9 – Relaxation (PREMIUM)
        ExerciseDefinition(
            index: 9, name: NSLocalizedString("Warm Compress", comment: ""), duration: 300, motionType: .warmth,
            hint: NSLocalizedString("Apply a warm, damp cloth over closed eyes. The heat helps open oil glands in your eyelids. Breathe deeply and relax for 3 minutes.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("A warm-compress style routine often used in dry-eye self-care.", comment: ""),
            sfSymbol: "flame.fill"
        ),
        // 10 – Binocular (PREMIUM)
        ExerciseDefinition(
            index: 10, name: NSLocalizedString("Stereogram", comment: ""), duration: 90, motionType: .stereo,
            hint: NSLocalizedString("Two circles will appear side by side. Relax your eyes and let them slowly merge into one. When you see a single circle, hold your focus.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("A practice routine for combining the views from both eyes.", comment: ""),
            sfSymbol: "circle.lefthalf.filled.righthalf.striped.horizontal"
        ),
        // 11 – Binocular (PREMIUM)
        ExerciseDefinition(
            index: 11, name: NSLocalizedString("Image Fusion", comment: ""), duration: 90, motionType: .fusion,
            hint: NSLocalizedString("Similar to stereogram, but the circles move apart and back together. Try to maintain fusion (single image) as long as possible.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("An advanced routine for shifting focus at changing distances.", comment: ""),
            sfSymbol: "circle.lefthalf.filled.righthalf.striped.horizontal.inverse"
        ),
        // 12 – Breathing (PREMIUM)
        ExerciseDefinition(
            index: 12, name: NSLocalizedString("Breath + Gaze", comment: ""), duration: 90, motionType: .breath,
            hint: NSLocalizedString("Sit upright, relax shoulders. Inhale 6 seconds — slowly raise your gaze. Hold 2 seconds at top. Exhale 7 seconds — lower your gaze. Repeat.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Combines eye movement with breathing rhythm for a calming routine.", comment: ""),
            sfSymbol: "wind"
        ),
        // 13 – Breathing (PREMIUM)
        ExerciseDefinition(
            index: 13, name: NSLocalizedString("20-20-20 Rule", comment: ""), duration: 20, motionType: .rule20,
            hint: NSLocalizedString("Every 20 minutes, look at something 20 feet away for 20 seconds. This exercise is a single guided 20-second break.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("A widely shared eye-care habit: every 20 minutes, look 20 feet away for 20 seconds.", comment: ""),
            sfSymbol: "clock.badge.checkmark"
        ),
        // 14 – Dry Eye Relief (PREMIUM)
        ExerciseDefinition(
            index: 14, name: NSLocalizedString("Lid Massage", comment: ""), duration: 60, motionType: .lidmassage,
            hint: NSLocalizedString("Using a fingertip, gently massage your upper eyelid from the temple toward the nose. Then do the same on the lower lid. Light pressure only.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("A gentle warming routine for the eyelids, common in dry-eye self-care.", comment: ""),
            sfSymbol: "hand.draw.fill"
        ),
        // 15 – Dry Eye Relief (PREMIUM)
        ExerciseDefinition(
            index: 15, name: NSLocalizedString("Lid Gym", comment: ""), duration: 80, motionType: .lidgym,
            hint: NSLocalizedString("Squeeze your eyes shut firmly for 2 seconds, then open wide for 2 seconds. This strengthens orbicularis and levator muscles.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("A practice routine for full, complete blinks.", comment: ""),
            sfSymbol: "eye.trianglebadge.exclamationmark.fill"
        ),
        // 16 – Dry Eye Relief (PREMIUM)
        ExerciseDefinition(
            index: 16, name: NSLocalizedString("Tear Film", comment: ""), duration: 90, motionType: .tearfilm,
            hint: NSLocalizedString("Perform a slow, complete blink — close fully, hold 1 second, open. Then look at a distant point for 4 seconds. Repeat.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Combines intentional blinking with distance relaxation.", comment: ""),
            sfSymbol: "drop.fill"
        ),
    ]

    /// Lookup by index.
    static subscript(index: Int) -> ExerciseDefinition? {
        all.first { $0.index == index }
    }

    /// Premium threshold — exercises at this index or above are locked.
    static let premiumThreshold = 6
}

// MARK: – Steps Map

private extension ExerciseDefinition {
    static let stepsMap: [Int: [String]] = [
        0:  [NSLocalizedString("Hold phone at arm's length", comment: ""),
             NSLocalizedString("Focus on the on-screen dot while it's large", comment: ""),
             NSLocalizedString("When you hear the chime, look at a distant object across the room", comment: ""),
             NSLocalizedString("Next chime — back to the dot. Repeat.", comment: ""),
             NSLocalizedString("Keep your head still — only your eyes move", comment: "")],
        1:  [NSLocalizedString("Look straight ahead and relax your eyes", comment: ""),
             NSLocalizedString("Follow the dot along the figure-eight path", comment: ""),
             NSLocalizedString("Keep the movement smooth and controlled", comment: ""),
             NSLocalizedString("The direction automatically reverses at halftime — watch the arrow", comment: ""),
             NSLocalizedString("Keep your head still — only your eyes should move", comment: "")],
        2:  [NSLocalizedString("Rub your palms together until warm", comment: ""),
             NSLocalizedString("Cup warm palms gently over closed eyes", comment: ""),
             NSLocalizedString("No pressure on the eyeballs", comment: ""),
             NSLocalizedString("Breathe slowly and deeply", comment: ""),
             NSLocalizedString("Audio cues mark the start, halfway, and end", comment: "")],
        3:  [NSLocalizedString("Keep your head still, face the screen", comment: ""),
             NSLocalizedString("A dot will appear in one of 9 positions", comment: ""),
             NSLocalizedString("Snap your gaze to it as soon as it appears", comment: ""),
             NSLocalizedString("Hold until the dot moves to the next position", comment: ""),
             NSLocalizedString("Head still — only your eyes move", comment: "")],
        4:  [NSLocalizedString("Look straight ahead, face relaxed", comment: ""),
             NSLocalizedString("Slowly close your eyelids fully — no squinting", comment: ""),
             NSLocalizedString("Hold closed for 1 second", comment: ""),
             NSLocalizedString("Open slowly and gently", comment: ""),
             NSLocalizedString("Repeat every 5 seconds", comment: "")],
        5:  [NSLocalizedString("Hold phone at arm's length", comment: ""),
             NSLocalizedString("Focus on the on-screen dot while it's bright", comment: ""),
             NSLocalizedString("When the chime sounds, shift gaze to the most distant point you can see", comment: ""),
             NSLocalizedString("Next chime — return to the dot. Keep alternating.", comment: ""),
             NSLocalizedString("Head still throughout", comment: "")],
        6:  [NSLocalizedString("Hold phone at arm's length, focus on center dot", comment: ""),
             NSLocalizedString("Slowly bring the phone toward your nose", comment: ""),
             NSLocalizedString("Keep the dot single and clear", comment: ""),
             NSLocalizedString("When the dot doubles, move the phone back", comment: ""),
             NSLocalizedString("Repeat the approach slowly", comment: "")],
        7:  [NSLocalizedString("Follow the dot as it traces a square path", comment: ""),
             NSLocalizedString("Keep your eyes on the dot at all times", comment: ""),
             NSLocalizedString("After each lap the direction reverses automatically — the arrow shows which way", comment: ""),
             NSLocalizedString("Keep your head completely still", comment: "")],
        8:  [NSLocalizedString("Follow the dot as it moves up and down", comment: ""),
             NSLocalizedString("The dot naturally slows at each end position", comment: ""),
             NSLocalizedString("Halfway through, it switches to left-right movement", comment: ""),
             NSLocalizedString("Keep your head still throughout", comment: "")],
        9:  [NSLocalizedString("Apply a warm, damp cloth over closed eyes", comment: ""),
             NSLocalizedString("The warmth opens oil glands in your eyelids", comment: ""),
             NSLocalizedString("Breathe deeply and relax", comment: ""),
             NSLocalizedString("Maintain for the full 3 minutes", comment: "")],
        10: [NSLocalizedString("Two circles appear side by side", comment: ""),
             NSLocalizedString("Relax your eyes — let focus go soft", comment: ""),
             NSLocalizedString("Allow the circles to slowly merge into one", comment: ""),
             NSLocalizedString("Hold the fused single circle as long as possible", comment: "")],
        11: [NSLocalizedString("Watch the two circles on screen", comment: ""),
             NSLocalizedString("As they move apart, try to maintain single vision", comment: ""),
             NSLocalizedString("When they come back together, maintain fusion", comment: ""),
             NSLocalizedString("Relax your eyes if you see double", comment: "")],
        12: [NSLocalizedString("Sit upright, relax your shoulders", comment: ""),
             NSLocalizedString("Inhale for 6 seconds — slowly raise your gaze", comment: ""),
             NSLocalizedString("Hold at the top for 2 seconds", comment: ""),
             NSLocalizedString("Exhale for 7 seconds — lower your gaze", comment: ""),
             NSLocalizedString("Repeat the breathing cycle", comment: "")],
        13: [NSLocalizedString("Look away from your screen", comment: ""),
             NSLocalizedString("Find an object at least 20 feet away", comment: ""),
             NSLocalizedString("Focus on it for 20 seconds", comment: ""),
             NSLocalizedString("Let your eye muscles fully relax", comment: "")],
        14: [NSLocalizedString("Close your eyes gently", comment: ""),
             NSLocalizedString("Using a fingertip, massage upper lid temple-to-nose", comment: ""),
             NSLocalizedString("Use light pressure only", comment: ""),
             NSLocalizedString("Repeat on the lower lid", comment: ""),
             NSLocalizedString("Continue alternating for 60 seconds", comment: "")],
        15: [NSLocalizedString("Squeeze your eyes shut firmly for 2 seconds", comment: ""),
             NSLocalizedString("Open your eyes wide for 2 seconds", comment: ""),
             NSLocalizedString("Keep the rhythm steady", comment: ""),
             NSLocalizedString("Focus on complete, firm closures", comment: "")],
        16: [NSLocalizedString("Perform a slow, complete blink", comment: ""),
             NSLocalizedString("Close fully and hold for 1 second", comment: ""),
             NSLocalizedString("Open and look at a distant point", comment: ""),
             NSLocalizedString("Hold distant focus for 4 seconds", comment: ""),
             NSLocalizedString("Repeat the cycle", comment: "")],
    ]
}
