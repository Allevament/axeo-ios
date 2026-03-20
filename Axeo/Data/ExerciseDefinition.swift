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
            hint: NSLocalizedString("Keep the phone at arm's length. Focus on the dot for 3 seconds, then shift your gaze to a distant object (across the room). Head stays still throughout.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Great for people who work at a screen 6+ hours/day. Helps with nearsightedness prevention, eye focusing fatigue, and Computer Vision Syndrome.", comment: ""),
            sfSymbol: "scope"
        ),
        // 1 – Eye Movement
        ExerciseDefinition(
            index: 1, name: NSLocalizedString("Figure Eight", comment: ""), duration: 42, motionType: .eight,
            hint: NSLocalizedString("Follow the moving dot along the figure-eight path with your eyes only. Keep smooth, continuous movement — don't jump ahead.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Improves eye mobility and coordination. Helpful for people with restricted eye movement, or those recovering after eye muscle procedures.", comment: ""),
            sfSymbol: "infinity"
        ),
        // 2 – Relaxation
        ExerciseDefinition(
            index: 2, name: NSLocalizedString("Palming", comment: ""), duration: 60, motionType: .palm,
            hint: NSLocalizedString("Rub your palms together until warm, then gently cup them over your closed eyes. No pressure on the eyeballs. Breathe slowly and let your eyes relax in total darkness.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Instant relief for tired, overworked eyes. Recommended after long screen sessions or any time your eyes feel strained.", comment: ""),
            sfSymbol: "hand.raised.fill"
        ),
        // 3 – Eye Movement
        ExerciseDefinition(
            index: 3, name: NSLocalizedString("Saccades", comment: ""), duration: 45, motionType: .fixate,
            hint: NSLocalizedString("A dot lights up in one of 9 positions — jump your gaze to it immediately and hold for 2.5 seconds. Keep your head still; only move your eyes.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Helps with reading speed and accuracy. Useful for anyone who loses their place while reading or has trouble with quick eye movements.", comment: ""),
            sfSymbol: "circle.grid.3x3.fill"
        ),
        // 4 – Relaxation
        ExerciseDefinition(
            index: 4, name: NSLocalizedString("Blinking", comment: ""), duration: 45, motionType: .blink,
            hint: NSLocalizedString("Look straight ahead, face relaxed. Slowly close eyelids fully — no squinting. Hold 1 second. Open slowly. Repeat every 5 seconds.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Restores your natural blink rate, which drops 60% during screen use. Helps with dry, irritated eyes and eye fatigue.", comment: ""),
            sfSymbol: "eye.slash.fill"
        ),
        // 5 – Accommodation
        ExerciseDefinition(
            index: 5, name: NSLocalizedString("Window Dot", comment: ""), duration: 100, motionType: .mark,
            hint: NSLocalizedString("Place a small sticker on a window at eye level. Stand arm's length away. Focus on the dot for 10 seconds, then shift to a distant object outside for 10 seconds.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Classic optometry exercise for focusing flexibility. Great for people with accommodative insufficiency or early presbyopia symptoms.", comment: ""),
            sfSymbol: "dot.circle.and.hand.point.up.left.fill"
        ),
        // 6 – Binocular (PREMIUM)
        ExerciseDefinition(
            index: 6, name: NSLocalizedString("Convergence", comment: ""), duration: 80, motionType: .converge,
            hint: NSLocalizedString("Hold phone at arm's length, focus on the center dot. Slowly bring it toward your nose, keeping the dot single and clear. When it doubles, move back out.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Strengthens eye teaming. Helps with convergence insufficiency — common in people who get headaches or double vision while reading.", comment: ""),
            sfSymbol: "arrow.triangle.merge"
        ),
        // 7 – Eye Movement (PREMIUM)
        ExerciseDefinition(
            index: 7, name: NSLocalizedString("Square Tracing", comment: ""), duration: 64, motionType: .square,
            hint: NSLocalizedString("Follow the dot as it traces a square with your eyes. Direction alternates clockwise then counterclockwise each lap.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Strengthens all six eye muscles evenly. Especially helpful for people with eye movement asymmetry or post-surgical recovery.", comment: ""),
            sfSymbol: "square.dashed"
        ),
        // 8 – Eye Movement (PREMIUM)
        ExerciseDefinition(
            index: 8, name: NSLocalizedString("Vertical & Horizontal", comment: ""), duration: 50, motionType: .lines,
            hint: NSLocalizedString("Follow the dot: slowly up — pause — down — pause. 10 repetitions. Then left — pause — right — pause. 10 repetitions.", comment: ""),
            cvEnabled: true,
            indications: NSLocalizedString("Builds range of motion in all four cardinal directions. Good for people with restricted gaze or neck tension from screen use.", comment: ""),
            sfSymbol: "arrow.up.and.down.and.arrow.left.and.right"
        ),
        // 9 – Relaxation (PREMIUM)
        ExerciseDefinition(
            index: 9, name: NSLocalizedString("Warm Compress", comment: ""), duration: 180, motionType: .warmth,
            hint: NSLocalizedString("Apply a warm, damp cloth over closed eyes. The heat helps open oil glands in your eyelids. Breathe deeply and relax for 3 minutes.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Recommended by ophthalmologists for dry eye and meibomian gland dysfunction. The heat liquefies blocked oils to restore your tear film.", comment: ""),
            sfSymbol: "flame.fill"
        ),
        // 10 – Binocular (PREMIUM)
        ExerciseDefinition(
            index: 10, name: NSLocalizedString("Stereogram", comment: ""), duration: 90, motionType: .stereo,
            hint: NSLocalizedString("Two circles will appear side by side. Relax your eyes and let them slowly merge into one. When you see a single circle, hold your focus.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Trains your brain to fuse images from both eyes. Helps develop stereoscopic depth perception and binocular vision.", comment: ""),
            sfSymbol: "circle.lefthalf.filled.righthalf.striped.horizontal"
        ),
        // 11 – Binocular (PREMIUM)
        ExerciseDefinition(
            index: 11, name: NSLocalizedString("Image Fusion", comment: ""), duration: 60, motionType: .fusion,
            hint: NSLocalizedString("Similar to stereogram, but the circles move apart and back together. Try to maintain fusion (single image) as long as possible.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Advanced binocular training. Builds flexible vergence — the ability to maintain single vision at changing distances.", comment: ""),
            sfSymbol: "circle.lefthalf.filled.righthalf.striped.horizontal.inverse"
        ),
        // 12 – Breathing (PREMIUM)
        ExerciseDefinition(
            index: 12, name: NSLocalizedString("Breath + Gaze", comment: ""), duration: 75, motionType: .breath,
            hint: NSLocalizedString("Sit upright, relax shoulders. Inhale 6 seconds — slowly raise your gaze. Hold 2 seconds at top. Exhale 7 seconds — lower your gaze. Repeat.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Combines eye movement with breathing rhythm. Reduces overall tension, lowers intraocular pressure, and calms the nervous system.", comment: ""),
            sfSymbol: "wind"
        ),
        // 13 – Breathing (PREMIUM)
        ExerciseDefinition(
            index: 13, name: NSLocalizedString("20-20-20 Rule", comment: ""), duration: 20, motionType: .rule20,
            hint: NSLocalizedString("Every 20 minutes, look at something 20 feet away for 20 seconds. This exercise is a single guided 20-second break.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("The AAO's #1 recommendation for screen users. Prevents accommodative spasm and reduces digital eye strain.", comment: ""),
            sfSymbol: "clock.badge.checkmark"
        ),
        // 14 – Dry Eye Relief (PREMIUM)
        ExerciseDefinition(
            index: 14, name: NSLocalizedString("Lid Massage", comment: ""), duration: 60, motionType: .lidmassage,
            hint: NSLocalizedString("Using a fingertip, gently massage your upper eyelid from the temple toward the nose. Then do the same on the lower lid. Light pressure only.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Stimulates meibomian glands to produce healthy oils. Based on TFOS DEWS II dry eye management guidelines.", comment: ""),
            sfSymbol: "hand.draw.fill"
        ),
        // 15 – Dry Eye Relief (PREMIUM)
        ExerciseDefinition(
            index: 15, name: NSLocalizedString("Lid Gym", comment: ""), duration: 80, motionType: .lidgym,
            hint: NSLocalizedString("Squeeze your eyes shut firmly for 2 seconds, then open wide for 2 seconds. This strengthens orbicularis and levator muscles.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Builds eyelid muscle tone for better blink quality. Recommended for incomplete blinkers and people with lagophthalmos risk.", comment: ""),
            sfSymbol: "eye.trianglebadge.exclamationmark.fill"
        ),
        // 16 – Dry Eye Relief (PREMIUM)
        ExerciseDefinition(
            index: 16, name: NSLocalizedString("Tear Film", comment: ""), duration: 60, motionType: .tearfilm,
            hint: NSLocalizedString("Perform a slow, complete blink — close fully, hold 1 second, open. Then look at a distant point for 4 seconds. Repeat.", comment: ""),
            cvEnabled: false,
            indications: NSLocalizedString("Restores tear film stability. Combines intentional blinking with distance relaxation, per TFOS DEWS II guidelines.", comment: ""),
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
             NSLocalizedString("Focus on the on-screen dot for 3 seconds", comment: ""),
             NSLocalizedString("Shift gaze to a distant object across the room", comment: ""),
             NSLocalizedString("Hold distant focus for 3 seconds", comment: ""),
             NSLocalizedString("Keep your head still — only your eyes move", comment: "")],
        1:  [NSLocalizedString("Look straight ahead and relax your eyes", comment: ""),
             NSLocalizedString("Trace a figure-eight pattern in the air with your eyes", comment: ""),
             NSLocalizedString("Keep the movement smooth and controlled", comment: ""),
             NSLocalizedString("Reverse the direction halfway through", comment: ""),
             NSLocalizedString("Keep your head still — only your eyes should move", comment: "")],
        2:  [NSLocalizedString("Rub your palms together until warm", comment: ""),
             NSLocalizedString("Cup warm palms gently over closed eyes", comment: ""),
             NSLocalizedString("No pressure on the eyeballs", comment: ""),
             NSLocalizedString("Breathe slowly and deeply", comment: ""),
             NSLocalizedString("Let your eyes relax in total darkness", comment: "")],
        3:  [NSLocalizedString("Keep your head still, face the screen", comment: ""),
             NSLocalizedString("A dot will appear in one of 9 positions", comment: ""),
             NSLocalizedString("Jump your gaze to the dot immediately", comment: ""),
             NSLocalizedString("Hold focus on the dot for 2.5 seconds", comment: ""),
             NSLocalizedString("Wait for the next dot position", comment: "")],
        4:  [NSLocalizedString("Look straight ahead, face relaxed", comment: ""),
             NSLocalizedString("Slowly close your eyelids fully — no squinting", comment: ""),
             NSLocalizedString("Hold closed for 1 second", comment: ""),
             NSLocalizedString("Open slowly and gently", comment: ""),
             NSLocalizedString("Repeat every 5 seconds", comment: "")],
        5:  [NSLocalizedString("Place a small dot or sticker on a window at eye level", comment: ""),
             NSLocalizedString("Stand at arm's length from the window", comment: ""),
             NSLocalizedString("Focus on the dot for 10 seconds", comment: ""),
             NSLocalizedString("Shift focus to a distant object outside", comment: ""),
             NSLocalizedString("Hold distant focus for 10 seconds", comment: "")],
        6:  [NSLocalizedString("Hold phone at arm's length, focus on center dot", comment: ""),
             NSLocalizedString("Slowly bring the phone toward your nose", comment: ""),
             NSLocalizedString("Keep the dot single and clear", comment: ""),
             NSLocalizedString("When the dot doubles, move the phone back", comment: ""),
             NSLocalizedString("Repeat the approach slowly", comment: "")],
        7:  [NSLocalizedString("Follow the dot as it traces a square path", comment: ""),
             NSLocalizedString("Keep your eyes on the dot at all times", comment: ""),
             NSLocalizedString("Direction alternates each lap", comment: ""),
             NSLocalizedString("Keep your head completely still", comment: "")],
        8:  [NSLocalizedString("Follow the dot as it moves up and down", comment: ""),
             NSLocalizedString("Pause briefly at each end position", comment: ""),
             NSLocalizedString("After 10 reps, follow left and right", comment: ""),
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
