import SwiftUI
import CoreText

/// Brand launch animation — premium, centred, large.
///
/// Sequence:
/// 1. Cross (X‑arms) scales + rotates in
/// 2. Retinal dot pulses onto the cross centre
/// 3. Dot slides right to the visual centre of the "o"
/// 4. Letters "a", "e", "o" slide up into place
/// 5. Tagline tracks in
/// 6. Fade out → onComplete
struct AXEOLaunchView: View {
    var onComplete: () -> Void

    // Animation phases
    @State private var showCross = false
    @State private var showDot = false
    @State private var dotSlid = false
    @State private var showLetters = false
    @State private var showTagline = false
    @State private var fadeOut = false

    // Anchor positions
    @State private var crossCenter: CGPoint = .zero
    @State private var oCenter: CGPoint = .zero

    private let ws = "ws"

    // Layout
    private let fontSize: CGFloat = 80
    private let crossW: CGFloat = 52
    private let crossH: CGFloat = 52
    private let dotSize: CGFloat = 12

    /// Correction from the text frame's geometric centre to the
    /// optical centre of lowercase round glyphs (specifically "o").
    ///
    /// Uses CoreText glyph bounding box for pixel-precise centering,
    /// then falls back to x-height midpoint if the CT lookup fails.
    private var glyphYCorrection: CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .light)

        // Try exact glyph bounds via CoreText
        let ctFont = font as CTFont
        var glyph: CGGlyph = 0
        var char: UniChar = 0x006F // 'o'
        if CTFontGetGlyphsForCharacters(ctFont, &char, &glyph, 1) {
            var bounds = CGRect.zero
            CTFontGetBoundingRectsForGlyphs(ctFont, .default, &glyph, &bounds, 1)
            // bounds.origin.y and bounds.size.height are in glyph space (y-up, origin at baseline)
            let glyphCenterFromBaseline = bounds.origin.y + bounds.size.height / 2
            let baselineFromTop = font.ascender
            let glyphCenterFromTop = baselineFromTop - glyphCenterFromBaseline
            let totalHeight = font.ascender - font.descender + font.leading
            let frameMidY = totalHeight / 2
            return glyphCenterFromTop - frameMidY
        }

        // Fallback: x-height midpoint
        let xHeightCenterFromTop = font.ascender - font.xHeight / 2
        let totalHeight = font.ascender - font.descender + font.leading
        let frameMidY = totalHeight / 2
        return xHeightCenterFromTop - frameMidY
    }

    var body: some View {
        ZStack {
            Color.aveoBg.ignoresSafeArea()

            VStack(spacing: 20) {
                // ── Wordmark ──────────────────────────────────
                ZStack {
                    HStack(alignment: .center, spacing: 2) {

                        // "a"
                        Text("a")
                            .font(.system(size: fontSize, weight: .light))
                            .foregroundStyle(Color.aveoText)
                            .opacity(showLetters ? 1 : 0)
                            .offset(y: showLetters ? 0 : 18)

                        // "x" — brand cross
                        XArmsShape()
                            .stroke(Color.aveoAccent,
                                    style: StrokeStyle(lineWidth: 3.6, lineCap: .round))
                            .frame(width: crossW, height: crossH)
                            .alignmentGuide(VerticalAlignment.center) { d in
                                d[VerticalAlignment.center] - glyphYCorrection
                            }
                            .scaleEffect(showCross ? 1 : 0.15)
                            .rotationEffect(.degrees(showCross ? 0 : -120))
                            .opacity(showCross ? 1 : 0)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: LaunchAnchorKey.self,
                                        value: [.cross: CGPoint(
                                            x: geo.frame(in: .named(ws)).midX,
                                            y: geo.frame(in: .named(ws)).midY
                                        )]
                                    )
                                }
                            )

                        // "e"
                        Text("e")
                            .font(.system(size: fontSize, weight: .light))
                            .foregroundStyle(Color.aveoText)
                            .opacity(showLetters ? 1 : 0)
                            .offset(y: showLetters ? 0 : 18)

                        // "o"
                        Text("o")
                            .font(.system(size: fontSize, weight: .light))
                            .foregroundStyle(Color.aveoText)
                            .opacity(showLetters ? 1 : 0)
                            .offset(y: showLetters ? 0 : 18)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: LaunchAnchorKey.self,
                                        value: [.oGlyph: CGPoint(
                                            x: geo.frame(in: .named(ws)).midX,
                                            y: geo.frame(in: .named(ws)).midY
                                                + glyphYCorrection + 5
                                        )]
                                    )
                                }
                            )
                    }

                    // ── Retinal dot with glow ring ──
                    if crossCenter != .zero {
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .stroke(Color.aveoRetinal.opacity(showDot ? 0.25 : 0), lineWidth: 1.5)
                                .frame(width: dotSize + 14, height: dotSize + 14)
                                .scaleEffect(showDot ? 1.3 : 0.5)

                            // Soft ambient glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.aveoRetinal.opacity(0.3), .clear],
                                        center: .center,
                                        startRadius: 2,
                                        endRadius: 20
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .opacity(showDot ? 1 : 0)

                            // Core dot
                            Circle()
                                .fill(Color.aveoRetinal)
                                .frame(width: dotSize, height: dotSize)
                                .shadow(color: Color.aveoRetinal.opacity(0.6),
                                        radius: showDot ? 12 : 0)
                        }
                        .scaleEffect(showDot ? 1 : 0)
                        .position(
                            x: dotSlid ? oCenter.x : crossCenter.x,
                            y: dotSlid
                                ? (oCenter != .zero ? oCenter.y + 3 : crossCenter.y)
                                : (oCenter != .zero ? oCenter.y - 5 : crossCenter.y)
                        )
                    }
                }
                .coordinateSpace(name: ws)
                .onPreferenceChange(LaunchAnchorKey.self) { anchors in
                    if let c = anchors[.cross]  { crossCenter = c }
                    if let o = anchors[.oGlyph] { oCenter = o }
                }

                // ── Tagline ──────────────────────────────────
                Text("E Y E   T R A I N I N G")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.aveoText3)
                    .tracking(showTagline ? 5 : 12)
                    .opacity(showTagline ? 1 : 0)
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear { runSequence() }
    }

    // MARK: – Animation Sequence (slower, more cinematic)

    private func runSequence() {
        // 0.4 s — Cross spins in (cinematic spring)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.4)) {
            showCross = true
        }

        // 1.0 s — Retinal dot appears at cross centre
        withAnimation(.spring(response: 0.45, dampingFraction: 0.35).delay(1.0)) {
            showDot = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            HapticManager.rigid()
            AudioManager.playLaunchChime()
        }

        // 1.7 s — Dot slides to "o" (smooth glide)
        withAnimation(.spring(response: 0.75, dampingFraction: 0.72).delay(1.7)) {
            dotSlid = true
        }

        // 2.3 s — Letters appear
        withAnimation(.spring(response: 0.65, dampingFraction: 0.75).delay(2.3)) {
            showLetters = true
        }

        // 3.1 s — Tagline
        withAnimation(.easeOut(duration: 0.8).delay(3.1)) {
            showTagline = true
        }

        // 4.3 s — Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                fadeOut = true
            }
        }

        // 4.8 s — Done
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
            onComplete()
        }
    }
}

// MARK: – Preference Key

private enum LaunchAnchorID: Hashable { case cross, oGlyph }

private struct LaunchAnchorKey: PreferenceKey {
    static var defaultValue: [LaunchAnchorID: CGPoint] = [:]
    static func reduce(value: inout [LaunchAnchorID: CGPoint],
                       nextValue: () -> [LaunchAnchorID: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: – X-Arms Shape

/// Four diagonal arms converging toward centre with a gap.
struct XArmsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let armLen = min(rect.width, rect.height) * 0.42
        let gap    = min(rect.width, rect.height) * 0.12

        for (dx, dy) in [(-1.0,-1.0),(1,-1),(-1,1),(1,1)] {
            path.move(to:    CGPoint(x: cx + dx * armLen, y: cy + dy * armLen))
            path.addLine(to: CGPoint(x: cx + dx * gap,    y: cy + dy * gap))
        }
        return path
    }
}

#Preview {
    AXEOLaunchView { }
        .preferredColorScheme(.dark)
}
