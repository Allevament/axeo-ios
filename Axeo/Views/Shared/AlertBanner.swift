import SwiftUI

struct AlertBanner: View {
    let message: String
    var variant: Variant = .info
    var icon: String? = nil

    enum Variant {
        case info, warning, success

        var color: Color {
            switch self {
            case .info:    .aveoAccent
            case .warning: .aveoWarning
            case .success: .aveoSuccess
            }
        }

        var defaultIcon: String {
            switch self {
            case .info:    "info.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            case .success: "checkmark.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon ?? variant.defaultIcon)
                .font(.system(size: 16))
                .foregroundStyle(variant.color)

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.aveoText2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(variant.color.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(variant.color.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AlertBanner(message: "This is an informational banner.", variant: .info)
        AlertBanner(message: "Consult a professional before starting.", variant: .warning)
        AlertBanner(message: "Exercise completed successfully!", variant: .success)
    }
    .padding()
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
