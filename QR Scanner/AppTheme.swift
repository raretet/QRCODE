import SwiftUI

enum AppTheme {
    enum Colors {
        static let background = Color(red: 0.97, green: 0.97, blue: 0.99)
        static let surfaceTop = Color(red: 0.99, green: 0.99, blue: 1.00)
        static let card = Color.white
        static let cardSoft = Color(red: 0.95, green: 0.95, blue: 0.99)
        static let ink = Color(red: 0.09, green: 0.10, blue: 0.17)
        static let secondaryInk = Color(red: 0.45, green: 0.48, blue: 0.58)
        static let tertiaryInk = Color(red: 0.63, green: 0.66, blue: 0.75)
        static let line = Color(red: 0.89, green: 0.90, blue: 0.95)
        static let brand = Color(red: 0.43, green: 0.30, blue: 1.00)
        static let brandDark = Color(red: 0.26, green: 0.17, blue: 0.73)
        static let brandSoft = Color(red: 0.93, green: 0.91, blue: 1.00)
        static let accent = Color(red: 0.08, green: 0.86, blue: 0.73)
        static let accentSoft = Color(red: 0.88, green: 0.98, blue: 0.95)
        static let warning = Color(red: 1.00, green: 0.78, blue: 0.25)
        static let warningSoft = Color(red: 1.00, green: 0.96, blue: 0.84)
        static let danger = Color(red: 1.00, green: 0.43, blue: 0.43)
        static let scanner = Color(red: 0.11, green: 0.12, blue: 0.18)
        static let overlay = Color.black.opacity(0.16)
        static let figmaInk = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
        static let figmaMuted = Color(red: 90 / 255, green: 90 / 255, blue: 90 / 255)
        static let figmaLine = Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
        static let figmaCanvas = Color(red: 246 / 255, green: 247 / 255, blue: 250 / 255)
        static let figmaScanBlue = Color(red: 0x7A / 255, green: 0xCB / 255, blue: 1)
        static let figmaCreateGreen = Color(red: 0x77 / 255, green: 0xC9 / 255, blue: 0x7E / 255)
        static let figmaMyOrange = Color(red: 1, green: 0xBB / 255, blue: 0x6C / 255)
        static let figmaTabInactive = Color(red: 176 / 255, green: 176 / 255, blue: 176 / 255)
    }

    enum HomeText {
        static let welcome = Font.system(size: 28, weight: .bold, design: .default)
        static let welcomeTracking: CGFloat = -0.5
        static let welcomeLineHeight: CGFloat = 42
        static let lead = Font.system(size: 15, weight: .regular, design: .default)
        static let leadTracking: CGFloat = -0.24
        static let section = Font.system(size: 22, weight: .regular, design: .default)
        static let sectionTracking: CGFloat = -0.41
        static let tileTitle = Font.system(size: 17, weight: .regular, design: .default)
        static let tileTitleTracking: CGFloat = -0.43
        static let tileCaption = Font.system(size: 13, weight: .regular, design: .default)
        static let tileCaptionTracking: CGFloat = -0.08
        static let rowTitle = Font.system(size: 17, weight: .regular, design: .default)
        static let rowTitleTracking: CGFloat = -0.43
        static let rowMeta = Font.system(size: 15, weight: .regular, design: .default)
        static let rowMetaTracking: CGFloat = -0.24
        static let tabLabel = Font.system(size: 10, weight: .medium, design: .default)
        static let tabLabelTracking: CGFloat = -0.12
    }
    
    enum Metrics {
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let cardRadius: CGFloat = 30
        static let mediumRadius: CGFloat = 24
        static let smallRadius: CGFloat = 18
        static let pillRadius: CGFloat = 14
        static let buttonHeight: CGFloat = 58
        static let inputHeight: CGFloat = 60
        static let tabBarHeight: CGFloat = 88
    }
}

struct AppShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(0.06), radius: 28, x: 0, y: 14)
    }
}

struct AppStroke: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: AppTheme.Metrics.cardRadius, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
    }
}

extension View {
    func appCardStyle(radius: CGFloat = AppTheme.Metrics.cardRadius) -> some View {
        self
            .background(AppTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .modifier(AppShadow())
    }
}
