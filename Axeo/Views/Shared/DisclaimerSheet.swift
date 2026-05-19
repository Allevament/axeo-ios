import SwiftUI

struct DisclaimerSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    /// Explicit user acknowledgement — Continue button is disabled until
    /// the user ticks the box. This converts a passive notice into the
    /// active consent that FTC / California ARL guidance favours for
    /// health-adjacent products.
    @State private var acknowledged = false

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.aveoAccent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "stethoscope")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.aveoAccent)
            }
            .padding(.top, 8)

            Text("Health Disclaimer")
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)

            Text("Axeo provides educational eye exercises for general wellness. It is not a medical device and does not diagnose, treat, cure, or prevent any disease. Axeo does not replace professional eye care. Consult a licensed ophthalmologist or optometrist before starting any exercise program — especially if you have a pre-existing condition or recent surgery.")
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Acknowledgement checkbox row
            Button {
                HapticManager.selection()
                withAnimation(.easeInOut(duration: 0.15)) {
                    acknowledged.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: acknowledged ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundStyle(acknowledged ? Color.aveoAccent : Color.aveoText3)
                    Text(NSLocalizedString("I understand that Axeo is not a medical device and does not diagnose or treat any condition. I will consult a professional if needed.", comment: ""))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.aveoText2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 4)
            }
            .buttonStyle(.plain)

            Button {
                HapticManager.medium()
                appState.hasSeenDisclaimer = true
                dismiss()
            } label: {
                Text(NSLocalizedString("Continue", comment: ""))
                    .font(.aveoHeadline)
                    .foregroundStyle(acknowledged ? Color.aveoBg : Color.aveoText3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if acknowledged {
                                LinearGradient.aveoAccentGradient
                            } else {
                                Color.aveoText3.opacity(0.15)
                            }
                        },
                        in: Capsule()
                    )
                    .shadow(color: acknowledged ? Color.aveoAccent.opacity(0.3) : .clear, radius: 12, y: 4)
            }
            .disabled(!acknowledged)
        }
        .padding(24)
        .background(Color.aveoBg.ignoresSafeArea())
        .interactiveDismissDisabled()
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            DisclaimerSheet()
                .environment(AppState())
        }
        .preferredColorScheme(.dark)
}
