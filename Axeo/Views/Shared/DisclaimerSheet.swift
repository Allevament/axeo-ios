import SwiftUI

struct DisclaimerSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

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

            Button {
                HapticManager.medium()
                appState.hasSeenDisclaimer = true
                dismiss()
            } label: {
                Text("I Understand — Let's Start")
                    .font(.aveoHeadline)
                    .foregroundStyle(Color.aveoBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient.aveoAccentGradient,
                        in: Capsule()
                    )
                    .shadow(color: Color.aveoAccent.opacity(0.3), radius: 12, y: 4)
            }
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
