import SwiftUI

// MARK: – Brand Icon Container

/// Renders one of the 5 ophthalmological brand icons in default or active state.
struct BrandIcon: View {
    enum Icon: String, CaseIterable {
        case landoltRing
        case amslerGrid
        case tumblingE
        case astigmatismDial
        case duochrome
    }

    let icon: Icon
    var isActive: Bool = false
    var size: CGFloat = 24

    private var strokeColor: Color { isActive ? .aveoAccent : Color(hex: 0x8A90A4) }
    private var dotColor: Color { .aveoRetinal }

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width
            switch icon {
            case .landoltRing:   drawLandoltRing(context: context, size: s)
            case .amslerGrid:    drawAmslerGrid(context: context, size: s)
            case .tumblingE:     drawTumblingE(context: context, size: s)
            case .astigmatismDial: drawAstigmatismDial(context: context, size: s)
            case .duochrome:     drawDuochrome(context: context, size: s)
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: – 1. Landolt Ring (ISO 8596)

    private func drawLandoltRing(context: GraphicsContext, size: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = size * 0.375  // 9/24 ratio from SVG
        let lineWidth = size * 0.0625  // 1.5/24

        // 300° arc with gap at 3 o'clock
        var arc = Path()
        // Gap from -30° to +30° (60° gap at 3 o'clock)
        arc.addArc(center: center, radius: radius,
                   startAngle: .degrees(30), endAngle: .degrees(-30),
                   clockwise: true)

        context.stroke(arc, with: .color(strokeColor),
                      style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

        // Retinal dot at center (active only)
        if isActive {
            let dotR = size * 0.083
            let dotRect = CGRect(x: center.x - dotR, y: center.y - dotR,
                                width: dotR * 2, height: dotR * 2)
            context.fill(Path(ellipseIn: dotRect), with: .color(dotColor))
        }
    }

    // MARK: – 2. Amsler Grid

    private func drawAmslerGrid(context: GraphicsContext, size: CGFloat) {
        let inset = size * 0.125  // 3/24
        let gridSize = size - inset * 2
        let lineWidth = size * 0.0625
        let thinLine = size * 0.021

        // Outer rectangle
        let rect = CGRect(x: inset, y: inset, width: gridSize, height: gridSize)
        let rrect = Path(roundedRect: rect, cornerRadius: size * 0.042)
        context.stroke(rrect, with: .color(strokeColor),
                      style: StrokeStyle(lineWidth: lineWidth))

        // Grid lines (4 vertical + 4 horizontal)
        let gridOpacity: Double = isActive ? 0.3 : 0.4
        let gridColor = strokeColor.opacity(gridOpacity)
        for i in 1...4 {
            let frac = CGFloat(i) / 5.0
            // Vertical
            var vLine = Path()
            vLine.move(to: CGPoint(x: inset + gridSize * frac, y: inset))
            vLine.addLine(to: CGPoint(x: inset + gridSize * frac, y: inset + gridSize))
            context.stroke(vLine, with: .color(gridColor),
                          style: StrokeStyle(lineWidth: thinLine))
            // Horizontal
            var hLine = Path()
            hLine.move(to: CGPoint(x: inset, y: inset + gridSize * frac))
            hLine.addLine(to: CGPoint(x: inset + gridSize, y: inset + gridSize * frac))
            context.stroke(hLine, with: .color(gridColor),
                          style: StrokeStyle(lineWidth: thinLine))
        }

        // Center dot
        let center = CGPoint(x: size / 2, y: size / 2)
        let dotR = size * 0.075
        let dotRect = CGRect(x: center.x - dotR, y: center.y - dotR,
                            width: dotR * 2, height: dotR * 2)
        context.fill(Path(ellipseIn: dotRect),
                    with: .color(isActive ? dotColor : strokeColor))
    }

    // MARK: – 3. Tumbling E

    private func drawTumblingE(context: GraphicsContext, size: CGFloat) {
        let lineWidth = size * 0.0625
        let x1 = size * 0.167  // 4/24
        let lengths: [(end: CGFloat, opacity: Double)] = [
            (size * 0.833, isActive ? 1.0 : 1.0),   // 20/24 — longest
            (size * 0.667, isActive ? 0.7 : 1.0),   // 16/24 — medium
            (size * 0.500, isActive ? 0.4 : 1.0),   // 12/24 — shortest
        ]
        let ys = [size * 0.3125, size * 0.5, size * 0.6875]  // 7.5, 12, 16.5 / 24

        for (i, y) in ys.enumerated() {
            var line = Path()
            line.move(to: CGPoint(x: x1, y: y))
            line.addLine(to: CGPoint(x: lengths[i].end, y: y))
            context.stroke(line, with: .color(strokeColor.opacity(lengths[i].opacity)),
                          style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }

    // MARK: – 4. Astigmatism Dial

    private func drawAstigmatismDial(context: GraphicsContext, size: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let reach = size * 0.375

        // 8 meridian lines at 0°, 22.5°, 45°, 67.5°, 90°, 112.5°, 135°, 157.5°
        let angles: [(deg: Double, width: CGFloat, opacity: Double)] = [
            (0,     size * 0.0625, 1.0),     // Vertical — cardinal
            (90,    size * 0.0625, 1.0),     // Horizontal — cardinal
            (45,    size * 0.042,  isActive ? 0.5 : 0.6),   // Diagonal
            (135,   size * 0.042,  isActive ? 0.5 : 0.6),   // Diagonal
            (22.5,  size * 0.031,  isActive ? 0.25 : 0.35), // Intermediate
            (67.5,  size * 0.031,  isActive ? 0.25 : 0.35),
            (112.5, size * 0.031,  isActive ? 0.25 : 0.35),
            (157.5, size * 0.031,  isActive ? 0.25 : 0.35),
        ]

        for a in angles {
            let rad = a.deg * .pi / 180
            let dx = cos(rad) * reach
            let dy = sin(rad) * reach
            var line = Path()
            line.move(to: CGPoint(x: center.x - dx, y: center.y - dy))
            line.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))
            context.stroke(line, with: .color(strokeColor.opacity(a.opacity)),
                          style: StrokeStyle(lineWidth: a.width, lineCap: .round))
        }

        // Center dot
        let dotR = size * 0.0625
        let dotRect = CGRect(x: center.x - dotR, y: center.y - dotR,
                            width: dotR * 2, height: dotR * 2)
        context.fill(Path(ellipseIn: dotRect),
                    with: .color(isActive ? dotColor : strokeColor))
    }

    // MARK: – 5. Duochrome Test

    private func drawDuochrome(context: GraphicsContext, size: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = size * 0.375
        let lineWidth = size * 0.0625

        // Circle stroke
        let circle = Path(ellipseIn: CGRect(
            x: center.x - radius, y: center.y - radius,
            width: radius * 2, height: radius * 2
        ))
        context.stroke(circle, with: .color(strokeColor),
                      style: StrokeStyle(lineWidth: lineWidth))

        // Bottom-left half fill (diagonal split)
        var halfPath = Path()
        halfPath.move(to: CGPoint(x: center.x - radius, y: center.y + radius))
        halfPath.addLine(to: CGPoint(x: center.x + radius, y: center.y - radius))
        halfPath.addArc(center: center, radius: radius,
                       startAngle: .degrees(-45), endAngle: .degrees(135),
                       clockwise: false)
        halfPath.closeSubpath()

        context.fill(halfPath, with: .color(strokeColor.opacity(isActive ? 0.15 : 0.2)))

        // Diagonal line
        var diag = Path()
        let diagOff = radius * cos(.pi / 4)
        diag.move(to: CGPoint(x: center.x - diagOff, y: center.y + diagOff))
        diag.addLine(to: CGPoint(x: center.x + diagOff, y: center.y - diagOff))
        context.stroke(diag, with: .color(strokeColor.opacity(isActive ? 0.6 : 1.0)),
                      style: StrokeStyle(lineWidth: size * 0.042))
    }
}

// MARK: – Tab Image Helper

extension BrandIcon {
    /// Renders the icon as an `Image` suitable for tab items.
    @MainActor
    static func tabImage(for icon: Icon, isActive: Bool = false, size: CGFloat = 24) -> Image {
        let view = BrandIcon(icon: icon, isActive: isActive, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage).renderingMode(.template)
        }
        return Image(systemName: "circle")
    }
}

// MARK: – Previews

#Preview("All Icons — Default") {
    HStack(spacing: 24) {
        ForEach(BrandIcon.Icon.allCases, id: \.rawValue) { icon in
            VStack(spacing: 8) {
                BrandIcon(icon: icon, isActive: false, size: 32)
                Text(icon.rawValue)
                    .font(.system(size: 8))
                    .foregroundStyle(Color.aveoText3)
            }
        }
    }
    .padding(32)
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}

#Preview("All Icons — Active") {
    HStack(spacing: 24) {
        ForEach(BrandIcon.Icon.allCases, id: \.rawValue) { icon in
            VStack(spacing: 8) {
                BrandIcon(icon: icon, isActive: true, size: 32)
                Text(icon.rawValue)
                    .font(.system(size: 8))
                    .foregroundStyle(Color.aveoText3)
            }
        }
    }
    .padding(32)
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
