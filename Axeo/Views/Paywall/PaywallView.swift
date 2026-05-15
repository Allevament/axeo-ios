import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .annual
    @State private var isPurchasing = false

    enum PlanType { case weekly, monthly, annual, lifetime }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    heroSection
                    featuresSection
                    planPicker
                    purchaseButton
                    restoreButton
                    legalText
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(AmbientBackground())
            .navigationTitle("Axeo Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
            .task {
                await storeManager.loadProducts()
                await storeManager.restorePurchases()
                if storeManager.isPremium {
                    appState.isPremium = true
                }
            }
        }
    }

    // MARK: – Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.aveoGold.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                BrandIcon(icon: .landoltRing, isActive: true, size: 56)
            }
            .padding(.top, 16)

            Text("Unlock Full Vision Training")
                .font(.aveoLargeTitle)
                .foregroundStyle(Color.aveoText)

            Text("Full access to 17 exercises, all programs, and premium features")
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText2)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: – Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(NSLocalizedString("17 structured exercises across 6 categories", comment: ""))
            featureRow(NSLocalizedString("3 structured programs (30–45 days)", comment: ""))
            featureRow(NSLocalizedString("6 vision screening tests", comment: ""))
            featureRow(NSLocalizedString("ARKit eye-tracking with accuracy scoring", comment: ""))
            featureRow(NSLocalizedString("Smart 20-20-20 reminders", comment: ""))
            featureRow(NSLocalizedString("New exercises & programs added regularly", comment: ""))
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aveoGlass)
                }
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.aveoGold.opacity(0.06), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.aveoGold.opacity(0.15), lineWidth: 0.5)
        }
        .aveoShadowMd()
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.aveoSuccess)
            Text(text)
                .font(.aveoBody)
                .foregroundStyle(Color.aveoText)
        }
    }

    // MARK: – Plan Picker

    private var planPicker: some View {
        VStack(spacing: 10) {
            // Annual — hero plan
            planCard(
                plan: .annual,
                title: NSLocalizedString("Annual", comment: ""),
                price: storeManager.annualProduct?.displayPrice ?? "$29.99",
                detail: NSLocalizedString("$2.49/mo · SAVE 58%", comment: ""),
                badge: "BEST VALUE",
                trial: NSLocalizedString("7-day free trial", comment: "")
            )

            // Monthly
            planCard(
                plan: .monthly,
                title: NSLocalizedString("Monthly", comment: ""),
                price: storeManager.monthlyProduct?.displayPrice ?? "$5.99",
                detail: NSLocalizedString("per month", comment: ""),
                badge: nil,
                trial: NSLocalizedString("7-day free trial", comment: "")
            )

            HStack(spacing: 10) {
                // Weekly
                planCardCompact(
                    plan: .weekly,
                    title: NSLocalizedString("Weekly", comment: ""),
                    price: storeManager.weeklyProduct?.displayPrice ?? "$2.99",
                    detail: NSLocalizedString("per week", comment: "")
                )

                // Lifetime
                planCardCompact(
                    plan: .lifetime,
                    title: NSLocalizedString("Lifetime", comment: ""),
                    price: storeManager.lifetimeProduct?.displayPrice ?? "$79.99",
                    detail: NSLocalizedString("one-time", comment: "")
                )
            }
        }
    }

    private func planCard(plan: PlanType, title: String, price: String, detail: String, badge: String?, trial: String?) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            HapticManager.selection()
            withAnimation(.spring(duration: 0.25)) { selectedPlan = plan }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
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
                    if let trial {
                        Text(trial)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.aveoSuccess)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(isSelected ? Color.aveoGold : Color.aveoText)
                    Text(detail)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.aveoText3)
                }
            }
            .padding(16)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aveoGold.opacity(0.08))
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aveoGlass)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.aveoGold.opacity(0.4) : Color.aveoGlassBorder, lineWidth: isSelected ? 1.5 : 0.5)
            }
        }
        .buttonStyle(.pressScale)
    }

    private func planCardCompact(plan: PlanType, title: String, price: String, detail: String) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            HapticManager.selection()
            withAnimation(.spring(duration: 0.25)) { selectedPlan = plan }
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.aveoText)
                Text(price)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(isSelected ? Color.aveoGold : Color.aveoText)
                Text(detail)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.aveoText3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aveoGold.opacity(0.08))
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aveoGlass)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.aveoGold.opacity(0.4) : Color.aveoGlassBorder, lineWidth: isSelected ? 1.5 : 0.5)
            }
        }
        .buttonStyle(.pressScale)
    }

    // MARK: – Purchase Button

    private var purchaseButton: some View {
        Button {
            HapticManager.medium()
            Task { await purchase() }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(Color.aveoBg)
                } else {
                    Text(purchaseButtonTitle)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .foregroundStyle(Color.aveoBg)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient.aveoGoldGradient,
                in: Capsule()
            )
            .shadow(color: Color.aveoGold.opacity(0.4), radius: 20, y: 6)
        }
        .disabled(isPurchasing)
    }

    private var purchaseButtonTitle: String {
        switch selectedPlan {
        case .weekly, .monthly, .annual:
            return NSLocalizedString("Start your 7-day free trial", comment: "")
        case .lifetime:
            return NSLocalizedString("Unlock forever", comment: "")
        }
    }

    private var restoreButton: some View {
        Button {
            HapticManager.light()
            Task {
                await storeManager.restorePurchases()
                if storeManager.isPremium {
                    appState.isPremium = true
                    HapticManager.success()
                    dismiss()
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.aveoCaption)
                .foregroundStyle(Color.aveoText3)
        }
    }

    private var legalText: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Subscription details")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.aveoText2)
                    .padding(.bottom, 2)
                Text("• Weekly plan: $2.99/week, billed weekly after a 3-day free trial.")
                Text("• Monthly plan: $5.99/month, billed monthly after a 7-day free trial.")
                Text("• Annual plan: $29.99/year, billed yearly after a 7-day free trial.")
                Text("• Lifetime: $79.99 one-time purchase, no renewal.")
                Text("• Subscriptions auto-renew at the same price each period until cancelled.")
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

            Text("By starting your subscription, you agree to the Terms of Service and Privacy Policy.")
                .font(.system(size: 10))
                .foregroundStyle(Color.aveoText3)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: – Actions

    private func purchase() async {
        let product: Product? = switch selectedPlan {
        case .weekly:   storeManager.weeklyProduct
        case .monthly:  storeManager.monthlyProduct
        case .annual:   storeManager.annualProduct
        case .lifetime: storeManager.lifetimeProduct
        }
        guard let product else { return }
        isPurchasing = true
        let success = await storeManager.purchase(product)
        isPurchasing = false
        if success {
            appState.isPremium = true
            HapticManager.success()
            dismiss()
        }
    }
}

#Preview {
    PaywallView()
        .environment(AppState())
        .environment(StoreManager())
        .preferredColorScheme(.dark)
}
