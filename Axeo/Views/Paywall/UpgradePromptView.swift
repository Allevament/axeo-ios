import SwiftUI

/// Contextual upgrade prompt — compact card shown inline after actions.
/// Used in: SessionResultView (post-workout), TestResultDetailView (post-test), ProfileView.
struct UpgradePromptView: View {
    let context: PromptContext
    let onTap: () -> Void

    enum PromptContext {
        case postSession(exerciseCount: Int)
        case postTest(testName: String)
        case profile
        case sessionGate(sessionCount: Int)
    }

    var body: some View {
        Button(action: {
            HapticManager.medium()
            onTap()
        }) {
            VStack(spacing: 10) {
                // Icon + headline
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.aveoGold.opacity(0.2), .clear],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: 18
                                )
                            )
                            .frame(width: 36, height: 36)

                        Image(systemName: iconName)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.aveoGold)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(headline)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.aveoText)
                            .lineLimit(1)

                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.aveoText2)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.aveoGold)
                }

                // CTA pill
                Text(ctaText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.aveoBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient.aveoGoldGradient,
                        in: Capsule()
                    )
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.aveoGold.opacity(0.06), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.aveoGold.opacity(0.2), lineWidth: 0.5)
            }
        }
        .buttonStyle(.pressScale)
    }

    // MARK: – Copy

    private var iconName: String {
        switch context {
        case .postSession:  "bolt.fill"
        case .postTest:     "chart.bar.fill"
        case .profile:      "star.fill"
        case .sessionGate:  "lock.open.fill"
        }
    }

    private var headline: String {
        switch context {
        case .postSession(let count):
            return String(format: NSLocalizedString("You trained %d exercises!", comment: ""), count)
        case .postTest(let name):
            return String(format: NSLocalizedString("%@ complete", comment: ""), name)
        case .profile:
            return NSLocalizedString("Upgrade to Premium", comment: "")
        case .sessionGate(let count):
            return String(format: NSLocalizedString("%d workouts done!", comment: ""), count)
        }
    }

    private var subtitle: String {
        switch context {
        case .postSession:
            return NSLocalizedString("Unlock 11 more exercises to accelerate your progress", comment: "")
        case .postTest:
            return NSLocalizedString("Get 4 advanced tests for deeper vision insights", comment: "")
        case .profile:
            return NSLocalizedString("All exercises, programs, and vision tests", comment: "")
        case .sessionGate:
            return NSLocalizedString("You're making real progress. Go unlimited.", comment: "")
        }
    }

    private var ctaText: String {
        switch context {
        case .sessionGate:
            return NSLocalizedString("Try 7 Days Free", comment: "")
        default:
            return NSLocalizedString("Try Premium Free", comment: "")
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        UpgradePromptView(context: .postSession(exerciseCount: 3)) {}
        UpgradePromptView(context: .postTest(testName: "Visual Acuity")) {}
        UpgradePromptView(context: .profile) {}
        UpgradePromptView(context: .sessionGate(sessionCount: 3)) {}
    }
    .padding()
    .background(Color.aveoBg)
    .preferredColorScheme(.dark)
}
