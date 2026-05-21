import StoreKit

@Observable
final class StoreManager {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false

    static let premiumWeeklyID   = "com.allevamentum.axeo.premium.weekly"
    static let premiumMonthlyID  = "com.allevamentum.axeo.premium.monthly"
    static let premiumAnnualID   = "com.allevamentum.axeo.premium.annual"
    static let premiumLifetimeID = "com.allevamentum.axeo.premium.lifetime"

    private static let allProductIDs: Set<String> = [
        premiumWeeklyID, premiumMonthlyID, premiumAnnualID, premiumLifetimeID
    ]

    var isPremium: Bool {
        !purchasedProductIDs.isDisjoint(with: Self.allProductIDs)
    }

    var weeklyProduct: Product?   { products.first { $0.id == Self.premiumWeeklyID } }
    var monthlyProduct: Product?  { products.first { $0.id == Self.premiumMonthlyID } }
    var annualProduct: Product?   { products.first { $0.id == Self.premiumAnnualID } }
    var lifetimeProduct: Product? { products.first { $0.id == Self.premiumLifetimeID } }

    // MARK: – Load Products

    func loadProducts() async {
        guard products.isEmpty else {
            #if DEBUG
            print("[StoreManager] Products already loaded: \(products.map(\.id))")
            #endif
            return
        }
        isLoading = true
        defer { isLoading = false }

        #if DEBUG
        print("[StoreManager] Loading products for IDs: \(Self.allProductIDs)")
        #endif
        do {
            let loaded = try await Product.products(for: Self.allProductIDs)
            products = loaded
            #if DEBUG
            print("[StoreManager] Loaded \(loaded.count) products: \(loaded.map { "\($0.id) → \($0.displayPrice)" })")
            if loaded.isEmpty {
                print("[StoreManager] ⚠️ No products returned. Check that Axeo.storekit is set in Scheme → Run → Options → StoreKit Configuration.")
            }
            #endif
        } catch {
            #if DEBUG
            print("[StoreManager] ❌ Failed to load products: \(error)")
            #endif
        }
    }

    // MARK: – Purchase

    func purchase(_ product: Product) async -> Bool {
        #if DEBUG
        print("[StoreManager] Purchasing: \(product.id) (\(product.displayPrice))")
        #endif
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            #if DEBUG
            print("[StoreManager] Purchase error: \(error)")
            #endif
            return false
        }
    }

    // MARK: – Restore

    func restorePurchases() async {
        // Refresh from canonical entitlement list. Clears revoked entitlements
        // so a refunded user no longer sees Premium after a manual Restore.
        var refreshed: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.revocationDate == nil {
                refreshed.insert(transaction.productID)
            }
        }
        purchasedProductIDs = refreshed
    }

    // MARK: – Listen for Updates

    func listenForTransactions(onChange: (@Sendable (Bool) -> Void)? = nil) async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerified(result) else { continue }
            // Handle revocation (refund / chargeback / expiry surfaced via
            // update). Without this branch, `isPremium` stayed `true` in
            // memory until the next cold launch even after a refund.
            if transaction.revocationDate != nil {
                purchasedProductIDs.remove(transaction.productID)
                #if DEBUG
                print("[StoreManager] Transaction revoked: \(transaction.productID), premium=\(isPremium)")
                #endif
            } else {
                purchasedProductIDs.insert(transaction.productID)
                #if DEBUG
                print("[StoreManager] Transaction update: \(transaction.productID), premium=\(isPremium)")
                #endif
            }
            await transaction.finish()
            onChange?(isPremium)
        }
    }

    // MARK: – Verify

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
