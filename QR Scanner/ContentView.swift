import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            switch appModel.route {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .main:
                MainTabContainerView()
            case .paywall:
                PricingView()
            case .settings:
                SettingsView()
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModel())
}
