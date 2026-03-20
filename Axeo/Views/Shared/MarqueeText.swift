import SwiftUI

/// A horizontally scrolling (marquee) text view for long labels.
struct MarqueeText: View {
    let text: String
    let font: Font
    let foregroundColor: Color
    let speed: Double // points per second

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var animating = false

    init(_ text: String,
         font: Font = .system(size: 11, weight: .medium),
         foregroundColor: Color = .aveoText3,
         speed: Double = 30) {
        self.text = text
        self.font = font
        self.foregroundColor = foregroundColor
        self.speed = speed
    }

    private var needsScroll: Bool { textWidth > containerWidth }
    private var gap: CGFloat { 40 }

    var body: some View {
        GeometryReader { geo in
            let containerW = geo.size.width
            ZStack(alignment: .leading) {
                if needsScroll {
                    HStack(spacing: gap) {
                        textLabel
                        textLabel
                    }
                    .offset(x: offset)
                    .onAppear {
                        containerWidth = containerW
                        startAnimation()
                    }
                    .onChange(of: textWidth) { _, _ in
                        startAnimation()
                    }
                } else {
                    textLabel
                }
            }
            .frame(width: containerW, alignment: .leading)
            .clipped()
            .onAppear {
                containerWidth = containerW
            }
        }
        .frame(height: textHeight)
    }

    private var textLabel: some View {
        Text(text)
            .font(font)
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .fixedSize()
            .background {
                GeometryReader { g in
                    Color.clear.onAppear {
                        textWidth = g.size.width
                    }
                }
            }
    }

    private var textHeight: CGFloat { 16 }

    private func startAnimation() {
        guard needsScroll else { return }
        offset = 0
        let totalDistance = textWidth + gap
        let duration = totalDistance / speed

        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset = -totalDistance
        }
    }
}
