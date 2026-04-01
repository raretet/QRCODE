import Foundation
import Combine
import AppTrackingTransparency
import AdSupport
import StoreKit
import ObjectiveC.runtime

#if canImport(AdServices)
import AdServices
#endif

#if canImport(AppsFlyerLib)
import AppsFlyerLib
#endif

#if canImport(ApphudSDK)
import ApphudSDK
#endif

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

struct AppIntegrationConfig {
    let apphudAPIKey: String
    let appsFlyerDevKey: String
    let appsFlyerAppID: String
    let apphudPlacementID: String
    let apphudPaywallID: String
    let weeklyProductID: String
    let monthlyProductID: String
    let yearlyProductID: String

    static func load() -> AppIntegrationConfig {
        let b = Bundle.main
        return AppIntegrationConfig(
            apphudAPIKey: (b.object(forInfoDictionaryKey: "APPHUD_API_KEY") as? String) ?? "",
            appsFlyerDevKey: (b.object(forInfoDictionaryKey: "APPSFLYER_DEV_KEY") as? String) ?? "",
            appsFlyerAppID: (b.object(forInfoDictionaryKey: "APPSFLYER_APP_ID") as? String) ?? "",
            apphudPlacementID: (b.object(forInfoDictionaryKey: "APPHUD_PLACEMENT_ID") as? String) ?? "",
            apphudPaywallID: (b.object(forInfoDictionaryKey: "APPHUD_PAYWALL_ID") as? String) ?? "",
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

final class AppIntegrationService: NSObject, ObservableObject {
    static let shared = AppIntegrationService()

    @Published private(set) var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    @Published private(set) var hasActiveSubscription: Bool = false
    @Published private(set) var lastConversionData: [String: Any] = [:]
    @Published private(set) var offers: [SubscriptionOffer] = []
    @Published private(set) var isPurchasing = false
    @Published private(set) var purchaseErrorText: String?
    @Published private(set) var apphudPlacementNames: [String] = []
    @Published private(set) var apphudPaywallNames: [String] = []
    @Published private(set) var apphudProductIDs: [String] = []

    private let config = AppIntegrationConfig.load()
    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        startApphud()
        setupAppsFlyer()
        requestTrackingPermission()
        sendFirebaseAttribution()
        sendAppleSearchAdsAttribution()
        Task { await loadOffers() }
        fetchApphudPaywallGraph()
    }

    func appDidBecomeActive() {
        #if canImport(AppsFlyerLib)
        AppsFlyerLib.shared().start()
        #endif
    }

    func refreshSubscriptionStatus() {
        #if canImport(ApphudSDK)
        hasActiveSubscription = Apphud.hasActiveSubscription()
        #else
        hasActiveSubscription = false
        #endif
    }

    func currentPlacementID() -> String { config.apphudPlacementID }
    func currentPaywallID() -> String { config.apphudPaywallID }

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

    private func startApphud() {
        #if canImport(ApphudSDK)
        guard !config.apphudAPIKey.isEmpty else { return }
        Apphud.start(apiKey: config.apphudAPIKey)
        refreshSubscriptionStatus()
        sendStoredAttributionToApphud()
        #endif
    }

    private func setupAppsFlyer() {
        #if canImport(AppsFlyerLib)
        guard !config.appsFlyerDevKey.isEmpty else { return }
        let af = AppsFlyerLib.shared()
        af.appsFlyerDevKey = config.appsFlyerDevKey
        af.appleAppID = config.appsFlyerAppID
        af.delegate = self
        af.waitForATTUserAuthorization(timeoutInterval: 60)
        #endif
    }

    private func requestTrackingPermission() {
        trackingStatus = ATTrackingManager.trackingAuthorizationStatus
        if trackingStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.trackingStatus = status
                    self?.syncTrackingStatusToAppsFlyer()
                }
            }
        } else {
            syncTrackingStatusToAppsFlyer()
        }
    }

    private func syncTrackingStatusToAppsFlyer() {
        #if canImport(AppsFlyerLib)
        _ = ATTrackingManager.trackingAuthorizationStatus
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 0)
        #endif
    }

    private func forwardAttributionToApphud(_ data: [String: Any]) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty("1", forName: "af_attribution_received")
        #endif
        sendAttributionToApphud(data: data, source: "appsflyer")
    }

    private func sendFirebaseAttribution() {
        #if canImport(FirebaseAnalytics)
        if let appInstanceID = Analytics.appInstanceID() {
            sendAttributionToApphud(data: ["app_instance_id": appInstanceID], source: "firebase")
        }
        #endif
    }

    private func sendAppleSearchAdsAttribution() {
        #if canImport(AdServices)
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
                sendAttributionToApphud(data: ["asa_token": token], source: "apple_search_ads")
            }
        }
        #endif
    }

    private func sendStoredAttributionToApphud() {
        if !lastConversionData.isEmpty {
            sendAttributionToApphud(data: lastConversionData, source: "appsflyer")
        }
    }

    private func sendAttributionToApphud(data: [String: Any], source: String) {
        #if canImport(ApphudSDK)
        guard let cls: AnyObject = NSClassFromString("Apphud") else { return }
        let candidates = [
            "addAttribution:data:identifier:",
            "setAttribution:data:identifier:",
            "setAttributionFrom:data:identifier:",
            "setAttribution:data:",
            "addAttribution:data:"
        ]
        for name in candidates {
            let sel = NSSelectorFromString(name)
            if cls.responds(to: sel) {
                switch name {
                case "setAttribution:data:":
                    _ = cls.perform(sel, with: source, with: data)
                case "addAttribution:data:":
                    _ = cls.perform(sel, with: source, with: data)
                default:
                    _ = cls.perform(sel, with: source, with: data)
                }
                return
            }
        }
        #endif
    }

    private func fetchApphudPaywallGraph() {
        #if canImport(ApphudSDK)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.readApphudObjectsRuntime()
        }
        #endif
    }

    private func readApphudObjectsRuntime() {
        #if canImport(ApphudSDK)
        guard let cls: AnyObject = NSClassFromString("Apphud") else { return }

        var placementsRaw: Any?
        var paywallsRaw: Any?

        let placementSelectors = ["placements", "getPlacements", "fetchPlacements"]
        for s in placementSelectors {
            let sel = NSSelectorFromString(s)
            if cls.responds(to: sel) {
                placementsRaw = cls.perform(sel)?.takeUnretainedValue()
                if placementsRaw != nil { break }
            }
        }

        let paywallSelectors = ["paywalls", "getPaywalls", "fetchPaywalls"]
        for s in paywallSelectors {
            let sel = NSSelectorFromString(s)
            if cls.responds(to: sel) {
                paywallsRaw = cls.perform(sel)?.takeUnretainedValue()
                if paywallsRaw != nil { break }
            }
        }

        let placements = extractArray(any: placementsRaw)
        let paywalls = extractArray(any: paywallsRaw)

        let placementNames = placements.compactMap { valueString(of: $0, keys: ["identifier", "id", "name"]) }.uniqued()
        let paywallNames = paywalls.compactMap { valueString(of: $0, keys: ["identifier", "id", "name"]) }.uniqued()
        let productIDs = paywalls.flatMap { valueArray(of: $0, key: "products") }.compactMap { valueString(of: $0, keys: ["productId", "id", "identifier"]) }.uniqued()

        DispatchQueue.main.async {
            self.apphudPlacementNames = placementNames
            self.apphudPaywallNames = paywallNames
            self.apphudProductIDs = productIDs
        }
        #endif
    }

    private func extractArray(any: Any?) -> [AnyObject] {
        if let arr = any as? [AnyObject] { return arr }
        if let ns = any as? NSArray { return ns.compactMap { $0 as AnyObject } }
        return []
    }

    private func valueString(of object: AnyObject, keys: [String]) -> String? {
        for key in keys {
            if let v = safeValue(of: object, key: key) as? String, !v.isEmpty { return v }
        }
        return nil
    }

    private func valueArray(of object: AnyObject, key: String) -> [AnyObject] {
        guard let raw = safeValue(of: object, key: key) else { return [] }
        if let arr = raw as? [AnyObject] { return arr }
        if let ns = raw as? NSArray { return ns.compactMap { $0 as AnyObject } }
        return []
    }

    private func safeValue(of object: AnyObject, key: String) -> Any? {
        let selector = NSSelectorFromString(key)
        if object.responds(to: selector) {
            return object.perform(selector)?.takeUnretainedValue()
        }
        return nil
    }
}

#if canImport(AppsFlyerLib)
extension AppIntegrationService: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        var converted: [String: Any] = [:]
        conversionInfo.forEach { key, value in
            converted[String(describing: key)] = value
        }
        lastConversionData = converted
        forwardAttributionToApphud(converted)
    }

    func onConversionDataFail(_ error: Error) {
        _ = error
    }

    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        var converted: [String: Any] = [:]
        attributionData.forEach { key, value in
            converted[String(describing: key)] = value
        }
        forwardAttributionToApphud(converted)
    }

    func onAppOpenAttributionFailure(_ error: Error) {
        _ = error
    }
}
#endif

private extension Array where Element == String {
    func uniqued() -> [String] {
        var set = Set<String>()
        var out: [String] = []
        for x in self where !set.contains(x) {
            set.insert(x)
            out.append(x)
        }
        return out
    }
}
