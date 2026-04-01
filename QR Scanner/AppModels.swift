import SwiftUI
import Combine

enum AppRoute {
    case splash
    case onboarding
    case main
    case paywall
}

enum MainTab: CaseIterable {
    case home
    case scan
    case create
    case myCodes
    case history
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .scan: return "Scan"
        case .create: return "Create"
        case .myCodes: return "My Codes"
        case .history: return "History"
        }
    }

    var tabBarLabel: String {
        switch self {
        case .home: return "Home"
        case .scan: return "Scan QR"
        case .create: return ""
        case .myCodes: return "My QR Codes"
        case .history: return "History"
        }
    }
}

enum QRContentType: String, CaseIterable, Identifiable, Codable {
    case website = "Website"
    case text = "Text"
    case phone = "Phone"
    case wifi = "Wi-Fi"
    case email = "Email"
    case contact = "Contact"
    
    var id: String { rawValue }
}

enum PaywallSource {
    case onboarding
    case feature
}

struct DashboardMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
}

enum HistoryEntryKind: String, Codable {
    case scanned
    case created
}

struct QRHistoryItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let payload: String
    let createdAt: Date
    let isFavorite: Bool
    let kind: HistoryEntryKind

    init(
        id: UUID = UUID(),
        title: String,
        payload: String,
        createdAt: Date = Date(),
        isFavorite: Bool,
        kind: HistoryEntryKind = .scanned
    ) {
        self.id = id
        self.title = title
        self.payload = payload
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.kind = kind
    }
}

struct MyQRCodeItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let type: QRContentType
    let payload: String
    let createdAt: Date
    let colorHex: String?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        type: QRContentType,
        payload: String,
        createdAt: Date = Date(),
        colorHex: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.payload = payload
        self.createdAt = createdAt
        self.colorHex = colorHex
    }
}

final class AppModel: ObservableObject {
    @Published var route: AppRoute = .splash
    @Published var selectedTab: MainTab = .home
    @Published var isPremium: Bool = false
    @Published var selectedCreationType: QRContentType = .website
    @Published var latestScan = QRHistoryItem(title: "Apple Support", payload: "https://support.apple.com/iphone", isFavorite: true)
    @Published var latestCreated = MyQRCodeItem(title: "Studio Wi-Fi", subtitle: "Network access for guests", type: .wifi, payload: "WIFI:S:Studio;T:WPA;P:password;;")
    
    let metrics: [DashboardMetric] = [
        DashboardMetric(title: "Scans", value: "128", subtitle: "+14 this week"),
        DashboardMetric(title: "Created", value: "24", subtitle: "6 templates used"),
        DashboardMetric(title: "Saved", value: "31", subtitle: "Across all lists")
    ]
    
    @Published var history: [QRHistoryItem] = [] {
        didSet { persist() }
    }
    
    @Published var myCodes: [MyQRCodeItem] = [] {
        didSet { persist() }
    }
    
    init() {
        hydrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.route = .onboarding
        }
    }
    
    func finishOnboarding() {
        route = .main
    }
    
    func showPaywall(source: PaywallSource) {
        _ = source
        route = .paywall
    }
    
    func closePaywall() {
        route = .main
    }
    
    func activatePremium() {
        isPremium = true
        route = .main
    }

    func addMyCode(type: QRContentType, payload: String, title: String? = nil, subtitle: String? = nil, colorHex: String? = nil) {
        let t = title ?? defaultTitle(for: type)
        let s = subtitle ?? defaultSubtitle(for: type, payload: payload)
        myCodes.insert(MyQRCodeItem(title: t, subtitle: s, type: type, payload: payload, colorHex: colorHex), at: 0)
    }

    func deleteMyCode(id: UUID) {
        myCodes.removeAll { $0.id == id }
    }

    func addHistory(kind: HistoryEntryKind = .scanned, type: QRContentType, payload: String, title: String? = nil) {
        let t = title ?? defaultTitle(for: type)
        history.insert(QRHistoryItem(title: t, payload: payload, isFavorite: false, kind: kind), at: 0)
        if history.count > 200 {
            history = Array(history.prefix(200))
        }
    }

    func deleteHistory(id: UUID) {
        history.removeAll { $0.id == id }
    }

    func clearHistory() {
        history.removeAll()
    }

    private func hydrate() {
        if let decoded = AppStorage.load() {
            history = decoded.history
            myCodes = decoded.myCodes
        }
    }

    private func persist() {
        AppStorage.save(AppStorage.Snapshot(history: history, myCodes: myCodes))
    }

    private func defaultTitle(for type: QRContentType) -> String {
        switch type {
        case .website: return "Website"
        case .text: return "Text"
        case .phone: return "Phone"
        case .wifi: return "Wi-Fi"
        case .email: return "Email"
        case .contact: return "Contact"
        }
    }

    private func defaultSubtitle(for type: QRContentType, payload: String) -> String {
        switch type {
        case .website:
            if let u = URL(string: payload), let host = u.host { return host }
            return payload
        case .text:
            return payload
        case .phone:
            return payload
        case .wifi:
            return payload
        case .email:
            return payload
        case .contact:
            return payload
        }
    }
}

private enum AppStorage {
    private static let key = "qr_scanner.storage.v1"

    struct Snapshot: Codable {
        let history: [QRHistoryItem]
        let myCodes: [MyQRCodeItem]
    }

    static func load() -> Snapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Snapshot.self, from: data)
    }

    static func save(_ snapshot: Snapshot) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
