import SwiftUI

@main
struct QR_ScannerApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var integrations = AppIntegrationService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .environmentObject(integrations)
                .task {
                    integrations.start()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                integrations.appDidBecomeActive()
                integrations.refreshSubscriptionStatus()
            }
        }
    }
}
