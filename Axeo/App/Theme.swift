import SwiftUI

// MARK: – Adaptive Color Tokens (AXEO Brand Book)

extension Color {

    // MARK: Adaptive helper

    /// Creates a colour that adapts between light and dark modes.
    static func adaptive(light: UInt, dark: UInt) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }

    // Surfaces — light: clean pearl-white, dark: deep midnight
    static let aveoBg  = adaptive(light: 0xF7F8FB, dark: 0x08090C)
    static let aveoBg2 = adaptive(light: 0xEFF0F5, dark: 0x12141A)
    static let aveoBg3 = adaptive(light: 0xFFFFFF, dark: 0x1C1F28)

    // Cards — light: pure white, dark: charcoal
    static let aveoCard  = adaptive(light: 0xFFFFFF, dark: 0x1C1F28)
    static let aveoCard2 = adaptive(light: 0xF3F4F9, dark: 0x12141A)

    // Borders — light: subtle cool grey, dark: slate
    static let aveoBorder  = adaptive(light: 0xE2E4EB, dark: 0x2A2E3A)
    static let aveoBorder2 = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0x2A2E3A, opacity: 0.6))
            : UIColor(Color(hex: 0xE2E4EB, opacity: 0.5))
    })

    // Signal — Optic Cyan (deeper on light for WCAG readability)
    static let aveoAccent = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0x00FFD5))
            : UIColor(Color(hex: 0x00A88C))
    })
    static let aveoAccent2 = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0x009B8A))
            : UIColor(Color(hex: 0x007A66))
    })
    static let aveoTeal = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0x00FFD5))
            : UIColor(Color(hex: 0x00A88C))
    })

    // Signal — Retinal Orange (slightly deeper on light for readability)
    static let aveoRetinal = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0xFF4500))
            : UIColor(Color(hex: 0xE83E00))
    })
    static let aveoRetinalDeep = Color(hex: 0xE03D00)

    // Functional (adaptive for legibility on light surfaces)
    static let aveoGold = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0xE09B3D))
            : UIColor(Color(hex: 0xC4872F))
    })
    static let aveoData = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0x3B82F6))
            : UIColor(Color(hex: 0x2563EB))
    })

    // Text — light: ink + grey hierarchy, dark: snow + muted
    static let aveoText  = adaptive(light: 0x1C1E26, dark: 0xEAECF0)
    static let aveoText2 = adaptive(light: 0x5A5E70, dark: 0x8A90A4)
    static let aveoText3 = adaptive(light: 0x9298AD, dark: 0x4A5068)

    // Semantic (adaptive for contrast on light surfaces)
    static let aveoSuccess = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0x22C55E))
            : UIColor(Color(hex: 0x16A34A))
    })
    static let aveoError = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0xEF4444))
            : UIColor(Color(hex: 0xDC2626))
    })
    static let aveoWarning = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(Color(hex: 0xE09B3D))
            : UIColor(Color(hex: 0xC4872F))
    })

    // Glass — adaptive for light/dark
    static let aveoGlass = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(white: 1, alpha: 0.72)
    })
    static let aveoGlassBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.12)
            : UIColor(white: 0, alpha: 0.06)
    })

    // MARK: – Hex Initialiser

    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: – Gradients

extension LinearGradient {
    static let aveoAccentGradient = LinearGradient(
        colors: [.aveoAccent, .aveoAccent2],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let aveoTealGradient = LinearGradient(
        colors: [.aveoTeal, .aveoRetinal],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let aveoGoldGradient = LinearGradient(
        colors: [.aveoGold, .aveoRetinal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let aveoRetinalGradient = LinearGradient(
        colors: [.aveoRetinal, .aveoRetinalDeep],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: – Typography

extension Font {
    /// Display heading — 24pt, light weight.
    static let aveoLargeTitle = Font.system(size: 24, weight: .light, design: .default)
    /// Section heading — 17pt, light weight.
    static let aveoTitle      = Font.system(size: 17, weight: .light, design: .default)
    /// Card heading — 15pt, medium.
    static let aveoHeadline   = Font.system(size: 15, weight: .medium, design: .default)
    /// Body text — 13pt regular.
    static let aveoBody       = Font.system(size: 13, weight: .regular, design: .default)
    /// Caption / secondary — 11pt medium.
    static let aveoCaption    = Font.system(size: 11, weight: .medium, design: .default)
    /// Overline / tiny label — 10pt semibold.
    static let aveoOverline   = Font.system(size: 10, weight: .semibold, design: .default)
    /// Data / timers — 48pt bold monospaced.
    static let aveoMono       = Font.system(size: 48, weight: .bold, design: .monospaced)
}

// MARK: – Shadow Modifiers (adaptive: softer on light, deeper on dark)

private struct AdaptiveShadow: ViewModifier {
    @Environment(\.colorScheme) private var cs
    let lightOpacity: Double
    let darkOpacity: Double
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(
            color: .black.opacity(cs == .dark ? darkOpacity : lightOpacity),
            radius: cs == .dark ? radius : radius * 0.6,
            y: cs == .dark ? y : y * 0.6
        )
    }
}

extension View {
    func aveoShadowSm() -> some View {
        modifier(AdaptiveShadow(lightOpacity: 0.04, darkOpacity: 0.25, radius: 4, y: 2))
    }

    func aveoShadowMd() -> some View {
        modifier(AdaptiveShadow(lightOpacity: 0.05, darkOpacity: 0.3, radius: 12, y: 6))
    }

    func aveoShadowLg() -> some View {
        modifier(AdaptiveShadow(lightOpacity: 0.07, darkOpacity: 0.4, radius: 24, y: 12))
    }
}

// MARK: – Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.aveoGlass)
                    }
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [Color.aveoGlassHighlight, .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
            )
            .aveoShadowMd()
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: – Ambient Background

/// Subtle animated mesh-like background with brand accent orbs.
/// Adapts orb intensity for light vs dark mode.
struct AmbientBackground: View {
    @Environment(\.colorScheme) private var cs
    @State private var animate = false

    private var tealOpacity: Double { cs == .dark ? 0.06 : 0.06 }
    private var retinalOpacity: Double { cs == .dark ? 0.04 : 0.04 }
    private var goldOpacity: Double { cs == .dark ? 0.03 : 0.03 }
    private var blurScale: CGFloat { cs == .dark ? 1.0 : 1.6 }

    var body: some View {
        ZStack {
            Color.aveoBg.ignoresSafeArea()

            // Teal orb — top-leading
            Circle()
                .fill(Color(hex: cs == .dark ? 0x00FFD5 : 0x00C9A7).opacity(tealOpacity))
                .frame(width: 300, height: 300)
                .blur(radius: 80 * blurScale)
                .offset(x: animate ? -100 : -120, y: animate ? -200 : -180)

            // Retinal orb — bottom-trailing
            Circle()
                .fill(Color(hex: cs == .dark ? 0xFF4500 : 0xE83E00).opacity(retinalOpacity))
                .frame(width: 250, height: 250)
                .blur(radius: 70 * blurScale)
                .offset(x: animate ? 120 : 100, y: animate ? 260 : 240)

            // Gold orb — centre-right
            Circle()
                .fill(Color(hex: cs == .dark ? 0xE09B3D : 0xC4872F).opacity(goldOpacity))
                .frame(width: 200, height: 200)
                .blur(radius: 60 * blurScale)
                .offset(x: animate ? 80 : 60, y: animate ? -20 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: – Press Scale Button Style

/// Apple-style press scale for interactive cards.
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressScaleButtonStyle {
    static var pressScale: PressScaleButtonStyle { PressScaleButtonStyle() }
}

// MARK: – Glow Accent Modifier

extension View {
    /// Adds a coloured glow behind the view — used for CTAs.
    func aveoGlow(_ color: Color, radius: CGFloat = 16, y: CGFloat = 4) -> some View {
        self.shadow(color: color.opacity(0.35), radius: radius, y: y)
    }
}

// MARK: – Adaptive Glass Highlight Color

extension Color {
    /// Top-edge highlight for glass cards: bright white in dark mode, soft white in light.
    static let aveoGlassHighlight = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.08)
            : UIColor(white: 1, alpha: 0.85)
    })
}
