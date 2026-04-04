import Foundation
import Combine
import StoreKit

struct AppIntegrationConfig {
    let weeklyProductID: String
    let monthlyProductID: String
    let yearlyProductID: String

    static func load() -> AppIntegrationConfig {
        let b = Bundle.main
        return AppIntegrationConfig(
            weeklyProductID: (b.object(forInfoDictionaryKey: "PRODUCT_ID_WEEKLY") as? String) ?? "sonicforge_weekly",
            monthlyProductID: (b.object(forInfoDictionaryKey: "PRODUCT_ID_MONTHLY") as? String) ?? "sonicforge_monthly",
            yearlyProductID: (b.object(forInfoDictionaryKey: "PRODUCT_ID_YEARLY") as? String) ?? "sonicforge_yearly"
        )
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }
}

struct SubscriptionOffer: Identifiable {
    let id: SubscriptionPlan
    let productID: String
    let title: String
    let periodText: String
    let priceText: String
    let currencyCode: String
    let product: Product?
}

final class AppIntegrationService: ObservableObject {
    static let shared = AppIntegrationService()

    @Published private(set) var hasActiveSubscription: Bool = false
    @Published private(set) var offers: [SubscriptionOffer] = []
    @Published private(set) var isPurchasing = false
    @Published private(set) var purchaseErrorText: String?

    private let config = AppIntegrationConfig.load()
    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        refreshSubscriptionStatus()
        Task { await loadOffers() }
    }

    func refreshSubscriptionStatus() {
        Task { @MainActor in
            await syncSubscriptionFromStoreKit()
        }
    }

    @MainActor
    private func syncSubscriptionFromStoreKit() async {
        let ids = Set(SubscriptionPlan.allCases.map { productID(for: $0) })
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let t) = result else { continue }
            guard ids.contains(t.productID) else { continue }
            if t.revocationDate != nil { continue }
            if let exp = t.expirationDate, exp <= Date() { continue }
            active = true
            break
        }
        hasActiveSubscription = active
    }

    func productID(for plan: SubscriptionPlan) -> String {
        switch plan {
        case .weekly: return config.weeklyProductID
        case .monthly: return config.monthlyProductID
        case .yearly: return config.yearlyProductID
        }
    }

    @MainActor
    func loadOffers() async {
        let ids = SubscriptionPlan.allCases.map { productID(for: $0) }
        do {
            let products = try await Product.products(for: ids)
            offers = SubscriptionPlan.allCases.map { plan in
                let pid = productID(for: plan)
                let product = products.first { $0.id == pid }
                let title: String
                let period: String
                switch plan {
                case .weekly:
                    title = "Weekly Plan"
                    period = "/ week"
                case .monthly:
                    title = "Monthly Plan"
                    period = "/ month"
                case .yearly:
                    title = "Yearly Plan"
                    period = "/ year"
                }
                let price = product?.displayPrice ?? "--"
                return SubscriptionOffer(
                    id: plan,
                    productID: pid,
                    title: title,
                    periodText: period,
                    priceText: price,
                    currencyCode: "",
                    product: product
                )
            }
        } catch {
            purchaseErrorText = error.localizedDescription
        }
    }

    @MainActor
    func purchase(plan: SubscriptionPlan) async {
        guard let offer = offers.first(where: { $0.id == plan }), let product = offer.product else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    refreshSubscriptionStatus()
                    hasActiveSubscription = true
                case .unverified(_, _):
                    purchaseErrorText = "Purchase verification failed"
                }
            case .pending:
                purchaseErrorText = "Purchase pending"
            case .userCancelled:
                purchaseErrorText = nil
            @unknown default:
                purchaseErrorText = "Unknown purchase result"
            }
        } catch {
            purchaseErrorText = error.localizedDescription
        }
    }

    @MainActor
    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            refreshSubscriptionStatus()
        } catch {
            purchaseErrorText = error.localizedDescription
        }
    }
}
