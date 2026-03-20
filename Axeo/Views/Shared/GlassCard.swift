import SwiftUI

/// A premium glass-effect card with optional accent border.
struct GlassCard<Content: View>: View {
    var accentColor: Color?
    var cornerRadius: CGFloat = 20
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
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
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        accentColor?.opacity(0.3) ?? Color.aveoGlassBorder,
                        lineWidth: 0.5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .aveoShadowMd()
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassCard {
            Text("Default glass card")
                .foregroundStyle(Color.aveoText)
        }

        GlassCard(accentColor: .aveoTeal) {
            HStack {
                Image(systemName: "eye.fill")
                    .foregroundStyle(Color.aveoTeal)
                Text("Teal accent card")
                    .foregroundStyle(Color.aveoText)
            }
        }
    }
    .padding()
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
