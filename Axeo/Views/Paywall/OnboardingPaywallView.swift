import SwiftUI
import StoreKit

/// Soft paywall shown at the end of onboarding.
/// Goal-aware: tailors the value proposition to the user's selected goal.
/// Always skippable — "Start Free" is visible but de-emphasized.
struct OnboardingPaywallView: View {
    let goal: User.Goal
    let onContinueFree: () -> Void

    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager
    @State private var selectedPlan: PlanType = .annual
    @State private var isPurchasing = false
    @State private var appeared = false

    enum PlanType { case monthly, annual }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                heroSection
                socialProof
                benefitsGrid
                planCards
                trialButton
                skipButton
                legalText
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background {
            ZStack {
                Color.aveoBg.ignoresSafeArea()
                RadialGradient(
                    colors: [Color.aveoGold.opacity(0.06), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
            }
        }
        .task {
            await storeManager.loadProducts()
        }
        .onAppear {
            withAnimation(.spring(duration: 0.7, bounce: 0.3).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.aveoGold.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(appeared ? 1.0 : 0.5)

                BrandIcon(icon: .landoltRing, isActive: true, size: 56)
                    .scaleEffect(appeared ? 1.0 : 0.4)
                    .opacity(appeared ? 1.0 : 0.0)
            }

            Text("Your Personal Plan\nis Ready")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.aveoText)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 12)

            Text(goalSubtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 8)
        }
        .padding(.top, 16)
    }

    private var goalSubtitle: String {
        switch goal {
        case .prevention:
            return NSLocalizedString("Based on your prevention goal, we've prepared\na daily routine to protect your vision", comment: "")
        case .correction:
            return NSLocalizedString("Based on your correction goal, we've designed\nexercises to strengthen your eye muscles", comment: "")
        case .relaxation:
            return NSLocalizedString("Based on your relaxation goal, we've curated\ncalming exercises to relieve eye strain", comment: "")
        }
    }

    // MARK: – Social Proof

    private var socialProof: some View {
        HStack(spacing: 8) {
            // Star rating
            HStack(spacing: 2) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.aveoGold)
                }
            }

            Text("4.8")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.aveoText)

            Text("·")
                .foregroundStyle(Color.aveoText3)

            Text(NSLocalizedString("Loved by thousands", comment: ""))
                .font(.system(size: 11))
                .foregroundStyle(Color.aveoText3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .overlay { Capsule().fill(Color.aveoGlass) }
        }
        .overlay {
            Capsule().strokeBorder(Color.aveoGlassBorder, lineWidth: 0.5)
        }
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    // MARK: – Benefits Grid

    private var benefitsGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

        return LazyVGrid(columns: columns, spacing: 10) {
            benefitCard(
                icon: "eye.fill",
                title: NSLocalizedString("17 Exercises", comment: ""),
                subtitle: NSLocalizedString("Structured exercises", comment: ""),
                gradient: [.aveoAccent, Color(hex: 0x0088CC)]
            )
            benefitCard(
                icon: "book.fill",
                title: NSLocalizedString("3 Programs", comment: ""),
                subtitle: NSLocalizedString("30–45 day courses", comment: ""),
                gradient: [.aveoTeal, .aveoSuccess]
            )
            benefitCard(
                icon: "tablecells",
                title: NSLocalizedString("6 Tests", comment: ""),
                subtitle: NSLocalizedString("Vision screening suite", comment: ""),
                gradient: [.aveoGold, .aveoRetinal]
            )
            benefitCard(
                icon: "scope",
                title: NSLocalizedString("Eye Tracking", comment: ""),
                subtitle: NSLocalizedString("ARKit accuracy scoring", comment: ""),
                gradient: [.aveoRetinal, Color(hex: 0xCC3300)]
            )
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 14)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }

    private func benefitCard(icon: String, title: String, subtitle: String, gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.linearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.aveoText)

            Text(subtitle)
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassCard(cornerRadius: 14, padding: 0)
    }

    // MARK: – Plan Cards

    private var planCards: some View {
        VStack(spacing: 8) {
            // Annual — hero
            planOption(
                plan: .annual,
                title: NSLocalizedString("Annual", comment: ""),
                price: storeManager.annualProduct?.displayPrice ?? "$29.99",
                perMonth: NSLocalizedString("$2.49/mo", comment: ""),
                badge: NSLocalizedString("SAVE 58%", comment: ""),
                trial: NSLocalizedString("7-day free trial", comment: "")
            )

            // Monthly
            planOption(
                plan: .monthly,
                title: NSLocalizedString("Monthly", comment: ""),
                price: storeManager.monthlyProduct?.displayPrice ?? "$5.99",
                perMonth: NSLocalizedString("per month", comment: ""),
                badge: nil,
                trial: NSLocalizedString("7-day free trial", comment: "")
            )
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 14)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
    }

    private func planOption(plan: PlanType, title: String, price: String, perMonth: String, badge: String?, trial: String) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            HapticManager.selection()
            withAnimation(.spring(duration: 0.25)) { selectedPlan = plan }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.aveoText)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.aveoRetinal))
                        }
                    }
                    Text(trial)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.aveoSuccess)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(isSelected ? Color.aveoGold : Color.aveoText)
                    Text(perMonth)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.aveoText3)
                }
            }
            .padding(14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aveoGold.opacity(0.08))
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay { RoundedRectangle(cornerRadius: 14).fill(Color.aveoGlass) }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.aveoGold.opacity(0.4) : Color.aveoGlassBorder, lineWidth: isSelected ? 1.5 : 0.5)
            }
        }
        .buttonStyle(.pressScale)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: – Trial Button

    private var trialButton: some View {
        Button {
            HapticManager.medium()
            Task { await purchase() }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(Color.aveoBg)
                } else {
                    VStack(spacing: 2) {
                        Text(NSLocalizedString("Try 7 Days Free", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                        Text(trialAfterText)
                            .font(.system(size: 11, weight: .medium))
                            .opacity(0.8)
                    }
                }
            }
            .foregroundStyle(Color.aveoBg)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient.aveoGoldGradient,
                in: Capsule()
            )
            .shadow(color: Color.aveoGold.opacity(0.4), radius: 20, y: 6)
        }
        .disabled(isPurchasing)
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
    }

    // MARK: – Skip (Start Free)

    private var skipButton: some View {
        Button {
            HapticManager.light()
            onContinueFree()
        } label: {
            Text(NSLocalizedString("Start Free with Limited Access", comment: ""))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.aveoText3)
        }
    }

    // MARK: – Legal

    private var legalText: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Subscription details")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.aveoText2)
                    .padding(.bottom, 2)
                Text("• Annual plan: $29.99/year, billed yearly after a 7-day free trial.")
                Text("• Monthly plan: $5.99/month, billed monthly after a 7-day free trial.")
                Text("• Subscription auto-renews at the same price each period until cancelled.")
                Text("• Cancel anytime in Settings > Apple ID > Subscriptions.")
                Text("• Payment is charged to your Apple ID at confirmation of purchase.")
                Text("• Trial converts to a paid subscription unless cancelled at least 24 hours before the trial ends.")
            }
            .font(.system(size: 11))
            .foregroundStyle(Color.aveoText3)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 18) {
                Link("Terms of Service", destination: URL(string: "https://axeo.vision/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://axeo.vision/privacy")!)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.aveoAccent)

            Text("By tapping \"Try 7 Days Free\", you agree to the Terms of Service and Privacy Policy.")
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
                .multilineTextAlignment(.center)
        }
    }

    /// Localised price-after-trial text. Uses StoreKit's auto-localised
    /// `displayPrice` for the currency formatting and an NSLocalizedString
    /// format key for the surrounding language. Previously this was a
    /// hardcoded `"then $29.99/year"` literal which broke localisation for
    /// non-English locales.
    private var trialAfterText: String {
        let format = selectedPlan == .annual
            ? NSLocalizedString("then %@/year", comment: "")
            : NSLocalizedString("then %@/month", comment: "")
        let price = selectedPlan == .annual
            ? (storeManager.annualProduct?.displayPrice ?? "$29.99")
            : (storeManager.monthlyProduct?.displayPrice ?? "$5.99")
        return String(format: format, price)
    }

    // MARK: – Purchase

    private func purchase() async {
        let product: Product? = switch selectedPlan {
        case .annual:  storeManager.annualProduct
        case .monthly: storeManager.monthlyProduct
        }
        guard let product else { return }
        isPurchasing = true
        let success = await storeManager.purchase(product)
        isPurchasing = false
        if success {
            appState.isPremium = true
            HapticManager.success()
            onContinueFree() // Complete onboarding
        }
    }
}

#Preview {
    OnboardingPaywallView(goal: .prevention) {}
        .environment(AppState())
        .environment(StoreManager())
        .preferredColorScheme(.dark)
}
