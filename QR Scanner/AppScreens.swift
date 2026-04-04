import SwiftUI
import UIKit
import Combine
import AVFoundation
import Vision
import PhotosUI

private func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

private enum OnboardingVisualTheme {
    static let background = Color(red: 0.985, green: 0.992, blue: 1.0)
    static let screenGradientTop = Color(red: 232 / 255, green: 247 / 255, blue: 1)
    static let cardBackground = Color(red: 0.89, green: 0.95, blue: 1.0)
    static let cardStroke = Color(red: 0.82, green: 0.86, blue: 0.91)
    static let title = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
    static let body = Color.black.opacity(0.58)
    static let button = Color(red: 0.38, green: 0.70, blue: 1.0)
    static let buttonPressed = Color(red: 0.31, green: 0.63, blue: 0.95)
    static let dotActive = Color(red: 0.38, green: 0.70, blue: 1.0)
    static let dotInactive = Color(red: 209 / 255, green: 213 / 255, blue: 219 / 255)
    static let skipLabel = Color(red: 90 / 255, green: 90 / 255, blue: 90 / 255)
    static let fieldStroke = Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
    static let fieldFill = Color(red: 246 / 255, green: 247 / 255, blue: 250 / 255)
    static let inputStrokeMint = Color(red: 232 / 255, green: 247 / 255, blue: 1)
    static let placeholderText = Color(red: 173 / 255, green: 174 / 255, blue: 188 / 255)
    static let qrModuleBlue = Color(red: 122 / 255, green: 203 / 255, blue: 1)
    static let manageMeta = Color(red: 176 / 255, green: 176 / 255, blue: 176 / 255)
    static let chipFill = Color(red: 246 / 255, green: 247 / 255, blue: 250 / 255)
    static let brandGradient = LinearGradient(
        colors: [
            Color(red: 122 / 255, green: 203 / 255, blue: 1),
            Color(red: 77 / 255, green: 166 / 255, blue: 1)
        ],
        startPoint: UnitPoint(x: 0.15, y: 1),
        endPoint: UnitPoint(x: 0.85, y: 0)
    )
    static let managePreviewGradient = LinearGradient(
        colors: [
            Color(red: 0x7A / 255, green: 0xCB / 255, blue: 0xFF / 255),
            Color(red: 0x4D / 255, green: 0xA6 / 255, blue: 0xFF / 255)
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )
}

private struct OnboardingStepData: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let headline: String?
    let detail: String?

    init(id: Int, title: String, subtitle: String, headline: String? = nil, detail: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.headline = headline
        self.detail = detail
    }
}

private let onboardingSteps: [OnboardingStepData] = [
    OnboardingStepData(
        id: 0,
        title: "Welcome",
        subtitle: "Scan, Create & Manage\nQR Codes Easily"
    ),
    OnboardingStepData(
        id: 1,
        title: "Scan QR Codes",
        subtitle: "Quickly Scan Any QR Code\nAlign QR codes in frame and get instant results"
    ),
    OnboardingStepData(
        id: 2,
        title: "Create QR Codes",
        subtitle: "",
        headline: "Generate QR Codes Instantly",
        detail: "Enter URL, text, or contact info and get \nyour custom QR"
    ),
    OnboardingStepData(
        id: 3,
        title: "Manage & Share",
        subtitle: "",
        headline: "Save, Share, and Track All\nYour QR Codes",
        detail: "Access My QR Codes and History anytime"
    )
]

struct SplashView: View {
    @State private var loadingDotPhase = 0

    private var marketingVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 375
            let sy = geo.size.height / 822

            ZStack {
                Color(red: 1, green: 1, blue: 1).ignoresSafeArea()

                SplashBackdropEllipses(sx: sx, sy: sy)
                    .allowsHitTesting(false)

                SplashBackdropRings()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(spacing: 50) {
                        SplashBrandBlock()
                        SplashLoadingRow(phase: loadingDotPhase)
                        Text("Version \(marketingVersion)")
                            .font(.system(size: 13, weight: .regular))
                            .tracking(-0.5)
                            .foregroundColor(Color(red: 176 / 255, green: 176 / 255, blue: 176 / 255))
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea()
        .onReceive(Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()) { _ in
            loadingDotPhase = (loadingDotPhase + 1) % 3
        }
    }
}

private struct SplashBrandColors {
    static let title = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
    static let subtitle = Color(red: 90 / 255, green: 90 / 255, blue: 90 / 255)
    static let dotBlue = Color(red: 122 / 255, green: 203 / 255, blue: 1)
    static let dotGreen = Color(red: 119 / 255, green: 201 / 255, blue: 126 / 255)
    static let dotOrange = Color(red: 255 / 255, green: 184 / 255, blue: 108 / 255)
    static let gradStart = Color(red: 122 / 255, green: 203 / 255, blue: 1)
    static let gradEnd = Color(red: 77 / 255, green: 166 / 255, blue: 1)
}

private struct SplashBackdropEllipses: View {
    let sx: CGFloat
    let sy: CGFloat

    var body: some View {
        ZStack {
            SplashBackdropEllipse(cx: -1.17 * sx, cy: 556.83 * sy, size: 97.66 * sx, color: SplashBrandColors.dotBlue, opacity: 0.14)
            SplashBackdropEllipse(cx: 60.08 * sx, cy: 694.85 * sy, size: 168.92 * sx, color: SplashBrandColors.dotGreen, opacity: 0.1)
            SplashBackdropEllipse(cx: 345.5 * sx, cy: 590.5 * sy, size: 87 * sx, color: SplashBrandColors.dotOrange, opacity: 0.06)
            SplashBackdropEllipse(cx: 360 * sx, cy: 253 * sy, size: 74 * sx, color: SplashBrandColors.dotBlue, opacity: 0.14)
            SplashBackdropEllipse(cx: 306.5 * sx, cy: 136.5 * sy, size: 87 * sx, color: SplashBrandColors.dotOrange, opacity: 0.06)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SplashBackdropEllipse: View {
    let cx: CGFloat
    let cy: CGFloat
    let size: CGFloat
    let color: Color
    let opacity: Double

    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .position(x: cx, y: cy)
    }
}

private struct SplashBackdropRings: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let center = CGPoint(x: w * 0.5, y: h * 0.5)
            ZStack {
                Circle()
                    .stroke(Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255), lineWidth: 2)
                    .frame(width: w * 1.16, height: w * 1.16)
                    .opacity(0.086)
                    .position(center)
                Circle()
                    .stroke(Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255), lineWidth: 2)
                    .frame(width: w * 1.27, height: w * 1.27)
                    .opacity(0.326)
                    .position(center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct SplashBrandBlock: View {
    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(SplashBrandColors.dotBlue)
                .frame(width: 12, height: 12)
                .offset(x: 101, y: -16)
            Circle()
                .fill(SplashBrandColors.dotGreen)
                .frame(width: 8, height: 8)
                .offset(x: -90, y: 246)
            Circle()
                .fill(SplashBrandColors.dotOrange)
                .frame(width: 6, height: 6)
                .offset(x: -98, y: 26)

            VStack(spacing: 32) {
                SplashGradientMark()
                VStack(spacing: 8) {
                    Text("QR Master")
                        .font(.system(size: 34, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(SplashBrandColors.title)
                    Text("Scan • Create • Manage")
                        .font(.system(size: 17, weight: .regular))
                        .tracking(-0.5)
                        .foregroundColor(SplashBrandColors.subtitle)
                }
            }
        }
        .frame(width: 197, height: 245)
    }
}

private struct SplashGradientMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SplashBrandColors.gradStart,
                            SplashBrandColors.gradEnd
                        ],
                        startPoint: UnitPoint(x: 0.15, y: 1),
                        endPoint: UnitPoint(x: 0.85, y: 0)
                    )
                )
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.1))
            Image(systemName: "qrcode")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.white)
                .symbolRenderingMode(.monochrome)
        }
        .frame(width: 128, height: 128)
        .shadow(color: SplashBrandColors.dotBlue.opacity(0.45), radius: 17, x: 0, y: 0)
    }
}

private struct OnboardingProgressStrip: View {
    let currentStep: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                if i == currentStep {
                    Capsule()
                        .fill(OnboardingVisualTheme.brandGradient)
                        .frame(width: 32, height: 8)
                } else {
                    Circle()
                        .fill(OnboardingVisualTheme.dotInactive)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.24), value: currentStep)
    }
}

private struct SplashLoadingRow: View {
    let phase: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(SplashBrandColors.dotBlue)
                        .frame(width: 8, height: 8)
                        .offset(y: yOffset(for: i))
                        .opacity(phase == i ? 1 : 0.45)
                        .animation(.easeInOut(duration: 0.35), value: phase)
                }
            }
            Text("Loading...")
                .font(.system(size: 15, weight: .regular))
                .tracking(-0.5)
                .foregroundColor(SplashBrandColors.subtitle)
        }
    }

    private func yOffset(for index: Int) -> CGFloat {
        switch index {
        case 0: return -1
        case 1: return -1.44
        default: return -1.73
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var currentStep = 0

    var body: some View {
        let step = onboardingSteps[currentStep]

        ZStack {
            Group {
                if step.id == 2 || step.id == 3 {
                    Color.white.ignoresSafeArea()
                } else {
                    LinearGradient(
                        colors: [OnboardingVisualTheme.screenGradientTop, Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
            }

            VStack(spacing: 0) {

                if step.id != 2 && step.id != 3 {
                    Spacer(minLength: 0)
                }

                VStack(spacing: 0) {
                    Group {
                        if step.id == 0 {
                            VStack(spacing: 0) {
                                Text(step.title)
                                    .font(.system(size: 36, weight: .bold))
                                    .tracking(-0.5)
                                    .foregroundColor(OnboardingVisualTheme.title)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 37)

                                onboardingGraphic(for: step.id)
                                    .frame(maxWidth: .infinity)

                                Text(step.subtitle)
                                    .font(.system(size: 24, weight: .semibold))
                                    .tracking(-0.5)
                                    .foregroundColor(OnboardingVisualTheme.title)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(10)
                                    .padding(.top, 38)
                                    .padding(.horizontal, 8)
                            }
                        } else if step.id == 1 {
                            VStack(spacing: 0) {
                                Text(step.title)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(OnboardingVisualTheme.title)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(7)
                                    .padding(.bottom, 43)

                                onboardingGraphic(for: step.id)
                                    .frame(maxWidth: .infinity)

                                VStack(spacing: 10) {
                                    Text("Quickly Scan Any QR Code")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(OnboardingVisualTheme.title)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(11)
                                    Text("Align QR codes in frame and get instant results")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(OnboardingVisualTheme.title)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(5)
                                }
                                .padding(.top, 43)
                                .padding(.horizontal, 8)
                            }
                        } else if step.id == 2 {
                            VStack(spacing: 0) {
                                Text(step.title)
                                    .font(.system(size: 36, weight: .bold))
                                    .tracking(-0.5)
                                    .foregroundColor(OnboardingVisualTheme.title)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 32)
                                    .padding(.bottom, 46)

                                onboardingGraphic(for: step.id)
                                    .frame(maxWidth: .infinity)

                                if let headline = step.headline, let detail = step.detail {
                                    VStack(spacing: 12) {
                                        Text(headline)
                                            .font(.system(size: 24, weight: .semibold))
                                            .tracking(-0.5)
                                            .foregroundColor(OnboardingVisualTheme.title)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(10)
                                        Text(detail)
                                            .font(.system(size: 16, weight: .regular))
                                            .tracking(-0.5)
                                            .foregroundColor(OnboardingVisualTheme.title)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(5)
                                    }
                                    .padding(.top, 47)
                                    .padding(.horizontal, 8)
                                }
                            }
                        } else if step.id == 3 {
                            VStack(spacing: 0) {
                                Text(step.title)
                                    .font(.system(size: 36, weight: .bold))
                                    .tracking(-0.5)
                                    .foregroundColor(OnboardingVisualTheme.title)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 32)
                                    .padding(.bottom, 29)

                                onboardingGraphic(for: step.id)
                                    .frame(maxWidth: .infinity)

                                if let headline = step.headline, let detail = step.detail {
                                    VStack(spacing: 6) {
                                        Text(headline)
                                            .font(.system(size: 24, weight: .semibold))
                                            .tracking(-0.5)
                                            .foregroundColor(OnboardingVisualTheme.title)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(10)
                                        Text(detail)
                                            .font(.system(size: 16, weight: .regular))
                                            .tracking(-0.5)
                                            .foregroundColor(OnboardingVisualTheme.title)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(4)
                                    }
                                    .padding(.top, 29)
                                    .padding(.horizontal, 8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: (currentStep == 2 || currentStep == 3) ? 0 : (currentStep == 0 ? 58 : (currentStep == 1 ? 43 : 36)))

                VStack(spacing: 0) {
                    HStack {
                        Spacer(minLength: 0)
                        OnboardingProgressStrip(currentStep: currentStep, total: onboardingSteps.count)
                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 29)

                    Button(action: advance) {
                        Text(currentStep == onboardingSteps.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 17, weight: .semibold))
                            .tracking(-0.5)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(OnboardingVisualTheme.brandGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PressedOpacityButtonStyle(pressedColor: OnboardingVisualTheme.buttonPressed))

                    if currentStep < onboardingSteps.count - 1 {
                        Button(action: { appModel.finishOnboarding() }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium))
                                .tracking(-0.5)
                                .foregroundColor(OnboardingVisualTheme.skipLabel)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 15)
                                .padding(.bottom, 6)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Spacer()
                            .frame(height: 45.5)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }

    private func advance() {
        if currentStep < onboardingSteps.count - 1 {
            withAnimation(.easeInOut(duration: 0.22)) {
                currentStep += 1
            }
        } else {
            appModel.finishOnboarding()
        }
    }
}



@ViewBuilder
private func onboardingGraphic(for index: Int) -> some View {
    switch index {
    case 0:
        BundleSVGView(resourceName: "onboarding1")
            .frame(width: 322, height: 291)
    case 1:
        BundleSVGView(resourceName: "onboarding2")
            .frame(width: 280, height: 280)
    case 2:
        OnboardingCreateGraphic()
    case 3:
        OnboardingManageGraphic()
    default:
        EmptyView()
    }
}

private struct PressedOpacityButtonStyle: ButtonStyle {
    let pressedColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : Color.clear)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct OnboardingCreateGraphic: View {
    private let blockW: CGFloat = 327
    private let innerW: CGFloat = 285.14
    private let inputH: CGFloat = 51.884
    private let inputCorner: CGFloat = 10.464
    private let generateH: CGFloat = 52.32
    private let generateCorner: CGFloat = 15.696
    private let qrFrameSide: CGFloat = 107
    private let qrSvgSide: CGFloat = 82

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 6.98) {
                    Text("Website URL")
                        .font(.system(size: 13.08, weight: .regular))
                        .tracking(-0.3)
                        .foregroundColor(OnboardingVisualTheme.title)

                    ZStack {
                        RoundedRectangle(cornerRadius: inputCorner, style: .continuous)
                            .fill(Color.white)
                        RoundedRectangle(cornerRadius: inputCorner, style: .continuous)
                            .stroke(OnboardingVisualTheme.inputStrokeMint, lineWidth: 1)
                        HStack(spacing: 8) {
                            Text("https://example.com")
                                .font(.system(size: 14.82, weight: .regular))
                                .foregroundColor(OnboardingVisualTheme.placeholderText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Spacer(minLength: 4)
                            Image(systemName: "globe")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color(red: 176 / 255, green: 176 / 255, blue: 176 / 255))
                        }
                        .padding(.horizontal, 13.95)
                    }
                    .frame(width: innerW, height: inputH)
                }
                .frame(width: innerW)
                Spacer(minLength: 0)
            }
            .frame(width: blockW)

            Spacer()
                .frame(height: 17.44)

            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("Generate QR Code")
                    .font(.system(size: 14.82, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: innerW, height: generateH)
                    .background(OnboardingVisualTheme.brandGradient)
                    .clipShape(RoundedRectangle(cornerRadius: generateCorner, style: .continuous))
                    .allowsHitTesting(false)
                Spacer(minLength: 0)
            }
            .frame(width: blockW)

            Spacer()
                .frame(height: 19.94)

            ZStack {
                RoundedRectangle(cornerRadius: 11.834, style: .continuous)
                    .fill(Color.white)
                RoundedRectangle(cornerRadius: 11.834, style: .continuous)
                    .stroke(OnboardingVisualTheme.fieldStroke, lineWidth: 1)
                BundleSVGView(resourceName: "onboarding-create-qr")
                    .frame(width: qrSvgSide, height: qrSvgSide)
            }
            .frame(width: qrFrameSide, height: qrFrameSide)
        }
        .frame(width: blockW)
    }
}

private struct OnboardingManageGraphic: View {
    private let gap: CGFloat = 10.844

    var body: some View {
        VStack(spacing: gap) {
            HStack(spacing: gap) {
                Spacer(minLength: 0)
                OnboardingManageMiniCard(
                    title: "My Website",
                    subtitle: "portfolio.com",
                    date: "Dec 15, 2024",
                    metric: "67"
                )
                OnboardingManageMiniCard(
                    title: "Contact Info",
                    subtitle: "John Doe vCard",
                    date: "Dec 12, 2024",
                    metric: "12"
                )
                Spacer(minLength: 0)
            }
            HStack(spacing: gap) {
                Spacer(minLength: 0)
                OnboardingManageMiniCard(
                    title: "My Website",
                    subtitle: "portfolio.com",
                    date: "Dec 15, 2024",
                    metric: "67"
                )
                OnboardingManageMiniCard(
                    title: "Contact Info",
                    subtitle: "John Doe vCard",
                    date: "Dec 12, 2024",
                    metric: "12"
                )
                Spacer(minLength: 0)
            }
        }
        .frame(width: 327)
    }
}

private struct OnboardingManageMiniCard: View {
    let title: String
    let subtitle: String
    let date: String
    let metric: String

    private let cardW: CGFloat = 105.389
    private let cardH: CGFloat = 147.409
    private let pad: CGFloat = 10.844
    private let outerCorner: CGFloat = 10.844
    private let innerCorner: CGFloat = 8.133
    private let previewW: CGFloat = 83.701
    private let previewH: CGFloat = 65.063
    private let gapPreviewToTitle: CGFloat = 8.13
    private let gapTextBlocks: CGFloat = 5.42
    private let chipSide: CGFloat = 16.266
    private let chipBarW: CGFloat = 6.862
    private let chipBarH: CGFloat = 1.779
    private let chartIconSize: CGFloat = 9.15

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                    .fill(OnboardingVisualTheme.managePreviewGradient)
                RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                    .stroke(OnboardingVisualTheme.fieldStroke, lineWidth: 1)
                Image(systemName: "qrcode")
                    .font(.system(size: 28.47, weight: .regular))
                    .foregroundColor(.white)
                    .symbolRenderingMode(.monochrome)
            }
            .frame(width: previewW, height: previewH)

            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(.system(size: 10.166, weight: .medium))
                    .tracking(-0.15)
                    .foregroundColor(OnboardingVisualTheme.title)
                    .lineLimit(1)
                Spacer(minLength: 4)
                ZStack {
                    Circle()
                        .fill(OnboardingVisualTheme.chipFill)
                    Circle()
                        .stroke(OnboardingVisualTheme.fieldStroke, lineWidth: 1)
                    RoundedRectangle(cornerRadius: 0.35, style: .continuous)
                        .fill(OnboardingVisualTheme.skipLabel)
                        .frame(width: chipBarW, height: chipBarH)
                }
                .frame(width: chipSide, height: chipSide)
            }
            .frame(width: previewW)
            .padding(.top, gapPreviewToTitle)

            Text(subtitle)
                .font(.system(size: 8.811, weight: .regular))
                .tracking(-0.1)
                .foregroundColor(OnboardingVisualTheme.skipLabel)
                .lineLimit(2)
                .frame(width: previewW, alignment: .leading)
                .padding(.top, gapTextBlocks)

            HStack(alignment: .center, spacing: 0) {
                Text(date)
                    .font(.system(size: 8.133, weight: .regular))
                    .foregroundColor(OnboardingVisualTheme.manageMeta)
                Spacer(minLength: 0)
                HStack(spacing: 2.71) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: chartIconSize * 0.78, weight: .medium))
                        .foregroundColor(OnboardingVisualTheme.manageMeta)
                    Text(metric)
                        .font(.system(size: 8.133, weight: .regular))
                        .foregroundColor(OnboardingVisualTheme.manageMeta)
                }
            }
            .frame(width: previewW)
            .padding(.top, gapTextBlocks)
        }
        .padding(pad)
        .frame(width: cardW, height: cardH, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: outerCorner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                .stroke(OnboardingVisualTheme.fieldStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.045), radius: 6, x: 0, y: 3)
    }
}

private struct TabBarNotchShape: Shape {
    var notchRadius: CGFloat = 40

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let midX = w * 0.5
        let R = min(notchRadius, max(midX - 4, 8))
        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: midX - R, y: 0))
        p.addArc(center: CGPoint(x: midX, y: 0), radius: R, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
        p.addLine(to: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return p
    }
}

struct MainTabContainerView: View {
    @EnvironmentObject private var appModel: AppModel

    private let tabBarFabReserve: CGFloat = 20
    private let tabBarHeight: CGFloat = 92

    private func homeIndicatorHeight(_ geo: GeometryProxy) -> CGFloat {
        let fromGeo = geo.safeAreaInsets.bottom
        if fromGeo > 0.5 { return fromGeo }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: \.isKeyWindow) ?? scene.windows.first
        else { return fromGeo }
        return max(fromGeo, window.safeAreaInsets.bottom)
    }

    var body: some View {
        GeometryReader { geo in
            let homeIndicatorH = homeIndicatorHeight(geo)
            let contentClearAboveBar = tabBarHeight + homeIndicatorH
            ZStack(alignment: .bottom) {
                Group {
                    switch appModel.selectedTab {
                    case .home: DashboardView()
                    case .scan: ScanView()
                    case .create: CreateQRView()
                    case .myCodes: MyCodesView()
                    case .history: HistoryView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, contentClearAboveBar)

                homeBottomNavigationBar(homeIndicatorFill: homeIndicatorH)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func homeBottomNavigationBar(homeIndicatorFill: CGFloat) -> some View {
        let fabSide: CGFloat = 52
        let notchR: CGFloat = 40

        return VStack(spacing: 0) {
            Color.clear.frame(height: tabBarFabReserve)
            ZStack {
                TabBarNotchShape(notchRadius: notchR)
                    .fill(AppTheme.Colors.card)
                    .frame(maxWidth: .infinity)
                    .frame(height: tabBarHeight)

                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        tabItem(.home)
                        tabItem(.scan)
                    }
                    .frame(maxWidth: .infinity)

                    Color.clear.frame(width: fabSide)

                    HStack(spacing: 0) {
                        tabItem(.myCodes)
                        tabItem(.history)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 8)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .frame(height: tabBarHeight)
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(AppTheme.Colors.card)
                .frame(height: max(homeIndicatorFill, 0.5))
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            HStack {
                Spacer(minLength: 0)
                Button {
                    appModel.openSettings()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.figmaCreateGreen)
                            .frame(width: fabSide, height: fabSide)
                            .shadow(color: AppTheme.Colors.figmaCreateGreen.opacity(0.5), radius: 12, x: 0, y: 0)
                            .shadow(color: Color.black.opacity(15 / 255), radius: 8, x: 0, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(14)
                    }
                    .frame(width: fabSide, height: fabSide)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L("settings.title"))
                Spacer(minLength: 0)
            }
        }
    }

    private func tabItem(_ tab: MainTab) -> some View {
        let isActive = appModel.selectedTab == tab
        return Button {
            appModel.selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                AppIconView(tab: tab, isActive: isActive)
                    .frame(height: 32)
                Text(tab.tabBarLabel)
                    .font(AppTheme.HomeText.tabLabel)
                    .tracking(AppTheme.HomeText.tabLabelTracking)
                    .foregroundColor(isActive ? AppTheme.Colors.figmaScanBlue : AppTheme.Colors.figmaTabInactive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardHomeActivity: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let circleColor: Color
    let symbolName: String
}

struct DashboardView: View {
    @EnvironmentObject private var appModel: AppModel

    private let gridGap: CGFloat = 16
    private let tileW: CGFloat = 155.5
    private let tileShortH: CGFloat = 177
    private let tileTallH: CGFloat = 202.5
    private var activities: [DashboardHomeActivity] {
        struct Entry {
            let date: Date
            let activity: DashboardHomeActivity
        }

        let scanned: [Entry] = appModel.history.map { item in
            let symbol: String
            switch item.kind {
            case .scanned:
                symbol = "qrcode.viewfinder"
            case .created:
                symbol = "qrcode"
            }
            return Entry(
                date: item.createdAt,
                activity: DashboardHomeActivity(
                    title: item.title,
                    time: RelativeTimeFormatter.string(from: item.createdAt),
                    circleColor: item.kind == .scanned ? AppTheme.Colors.figmaScanBlue : AppTheme.Colors.figmaCreateGreen,
                    symbolName: symbol
                )
            )
        }

        let created: [Entry] = appModel.myCodes.map { item in
            let symbol: String
            switch item.type {
            case .wifi: symbol = "wifi"
            case .contact: symbol = "person.crop.rectangle"
            case .email: symbol = "envelope"
            case .phone: symbol = "phone"
            case .website: symbol = "link"
            case .text: symbol = "textformat"
            }
            return Entry(
                date: item.createdAt,
                activity: DashboardHomeActivity(
                    title: "Created \(item.type.rawValue) QR",
                    time: RelativeTimeFormatter.string(from: item.createdAt),
                    circleColor: AppTheme.Colors.figmaCreateGreen,
                    symbolName: symbol
                )
            )
        }

        let merged = (scanned + created)
            .sorted { $0.date > $1.date }
            .prefix(6)
            .map { $0.activity }

        if merged.isEmpty {
            return [DashboardHomeActivity(title: "No activity yet", time: "Start by scanning or creating", circleColor: AppTheme.Colors.figmaTabInactive, symbolName: "clock")]
        }
        return merged
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome, User!")
                        .font(AppTheme.HomeText.welcome)
                        .tracking(AppTheme.HomeText.welcomeTracking)
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .lineSpacing(14)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, minHeight: AppTheme.HomeText.welcomeLineHeight, alignment: .leading)
                    Text("Manage your QR codes easily")
                        .font(AppTheme.HomeText.lead)
                        .tracking(AppTheme.HomeText.leadTracking)
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 56)

                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(spacing: gridGap) {
                        HStack(spacing: gridGap) {
                            DashboardQuickTile(
                                circleColor: AppTheme.Colors.figmaScanBlue,
                                symbol: "viewfinder",
                                title: "Scan QR",
                                subtitle: "Quick scan",
                                height: tileShortH
                            ) { appModel.selectedTab = .scan }
                            .frame(width: tileW)

                            DashboardQuickTile(
                                circleColor: AppTheme.Colors.figmaCreateGreen,
                                symbol: "qrcode",
                                title: "Create QR",
                                subtitle: "Generate new",
                                height: tileShortH
                            ) { appModel.selectedTab = .create }
                            .frame(width: tileW)
                        }

                        HStack(spacing: gridGap) {
                            DashboardQuickTileTall(
                                circleColor: AppTheme.Colors.figmaMyOrange,
                                symbol: "folder.fill",
                                titleLine1: "My QR",
                                titleLine2: "Codes",
                                subtitle: "Saved codes",
                                height: tileTallH
                            ) { appModel.selectedTab = .myCodes }
                            .frame(width: tileW)

                            DashboardQuickTile(
                                circleColor: AppTheme.Colors.figmaTabInactive,
                                symbol: "clock.fill",
                                title: "History",
                                subtitle: "Recent scans",
                                height: tileTallH
                            ) { appModel.selectedTab = .history }
                            .frame(width: tileW)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Recent Activity")
                            .font(AppTheme.HomeText.section)
                            .tracking(AppTheme.HomeText.sectionTracking)
                            .foregroundColor(AppTheme.Colors.figmaInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 49)
                            .padding(.bottom, 16)

                        VStack(spacing: 12) {
                            ForEach(activities) { item in
                                DashboardActivityRow(item: item)
                            }
                        }
                    }
                    .frame(width: 327, alignment: .leading)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .background(AppTheme.Colors.figmaCanvas.ignoresSafeArea())
    }
}

private struct DashboardQuickTile: View {
    let circleColor: Color
    let symbol: String
    let title: String
    let subtitle: String
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 64, height: 64)
                    Image(systemName: symbol)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)

                Text(title)
                    .font(AppTheme.HomeText.tileTitle)
                    .tracking(AppTheme.HomeText.tileTitleTracking)
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                Text(subtitle)
                    .font(AppTheme.HomeText.tileCaption)
                    .tracking(AppTheme.HomeText.tileCaptionTracking)
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardQuickTileTall: View {
    let circleColor: Color
    let symbol: String
    let titleLine1: String
    let titleLine2: String
    let subtitle: String
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 64, height: 64)
                    Image(systemName: symbol)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)

                VStack(spacing: 4.5) {
                    Text(titleLine1)
                        .font(AppTheme.HomeText.tileTitle)
                        .tracking(AppTheme.HomeText.tileTitleTracking)
                        .foregroundColor(AppTheme.Colors.figmaInk)
                    Text(titleLine2)
                        .font(AppTheme.HomeText.tileTitle)
                        .tracking(AppTheme.HomeText.tileTitleTracking)
                        .foregroundColor(AppTheme.Colors.figmaInk)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 16)

                Text(subtitle)
                    .font(AppTheme.HomeText.tileCaption)
                    .tracking(AppTheme.HomeText.tileCaptionTracking)
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardActivityRow: View {
    let item: DashboardHomeActivity

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.circleColor)
                    .frame(width: 40, height: 40)
                Image(systemName: item.symbolName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(AppTheme.HomeText.rowTitle)
                    .tracking(AppTheme.HomeText.rowTitleTracking)
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .lineSpacing(3)
                Text(item.time)
                    .font(AppTheme.HomeText.rowMeta)
                    .tracking(AppTheme.HomeText.rowMetaTracking)
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaTabInactive)
        }
        .padding(.horizontal, 16)
        .frame(height: 80)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
    }
}

private struct ScanViewfinderCornersShape: Shape {
    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 18
        let arm: CGFloat = 32
        var path = Path()
        path.move(to: CGPoint(x: inset + arm, y: inset))
        path.addLine(to: CGPoint(x: inset, y: inset))
        path.addLine(to: CGPoint(x: inset, y: inset + arm))
        path.move(to: CGPoint(x: rect.maxX - inset - arm, y: inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: inset + arm))
        path.move(to: CGPoint(x: inset, y: rect.maxY - inset - arm))
        path.addLine(to: CGPoint(x: inset, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: inset + arm, y: rect.maxY - inset))
        path.move(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset - arm))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset - arm, y: rect.maxY - inset))
        return path
    }
}

private struct ScanToolBarButton: View {
    let title: String
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.figmaCanvas)
                        .frame(width: 48, height: 48)
                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                }
                .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                Text(title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct ScanView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showResult = false
    @State private var scanPayload: String = ""
    @State private var scannedAt: Date = Date()
    @State private var isTorchOn = false
    @State private var isCameraAuthorized = false
    @State private var galleryItem: PhotosPickerItem?

    private let hPad: CGFloat = 24
    private let scanSize: CGFloat = 280

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text(L("scan.title"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, hPad)
                    .padding(.vertical, 16)
                    .background(Color.white)

                VStack(alignment: .leading, spacing: 0) {
                    scanHintCard
                        .padding(.horizontal, hPad)
                        .padding(.top, 24)

                    scanViewfinderBlock
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)

                    scanActionsCard
                        .padding(.horizontal, hPad)
                        .padding(.top, 32)
                        .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(AppTheme.Colors.figmaCanvas.ignoresSafeArea())
        .onAppear {
            updateCameraAuthorization()
        }
        .sheet(isPresented: $showResult) {
            let info = ScanPayloadClassifier.classify(scanPayload)
            ScanResultView(
                presentation: .compact,
                detectedType: info.detectedType,
                kindLabel: info.kindLabel,
                shortUrl: info.previewLine,
                fullUrl: info.payloadForDisplay,
                scannedAt: RelativeTimeFormatter.string(from: scannedAt),
                typeName: info.typeName
            )
        }
    }

    private var scanHintCard: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.figmaScanBlue)
                    .frame(width: 40, height: 40)
                Image(systemName: "viewfinder")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Align QR code within frame")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                Text("Keep your device steady")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaTabInactive)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
    }

    private var scanViewfinderBlock: some View {
        HStack {
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.Colors.figmaScanBlue, lineWidth: 1)
                    )
                if isCameraAuthorized {
                    CameraScannerView(isTorchOn: $isTorchOn) { payload in
                        scannedAt = Date()
                        scanPayload = payload
                        let info = ScanPayloadClassifier.classify(payload)
                        appModel.addHistory(kind: .scanned, type: info.contentType, payload: info.payloadForDisplay, title: info.titleForHistory)
                        showResult = true
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaTabInactive)
                        Text(L("scan.camera_required"))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                    }
                }
                ScanViewfinderCornersShape()
                    .stroke(AppTheme.Colors.figmaScanBlue.opacity(0.45), lineWidth: 2)
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 176)
                    Rectangle()
                        .fill(AppTheme.Colors.figmaLine)
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                    Spacer(minLength: 0)
                }
            }
            .frame(width: scanSize, height: scanSize)
            .contentShape(Rectangle())
            Spacer(minLength: 0)
        }
    }

    private var scanActionsCard: some View {
        HStack(spacing: 0) {
            ScanToolBarButton(title: isTorchOn ? L("scan.flash_on") : L("scan.flash_off"), systemName: isTorchOn ? "bolt.fill" : "bolt.slash.fill") {
                if isCameraAuthorized {
                    isTorchOn.toggle()
                }
            }
            ScanToolBarButton(title: L("common.history"), systemName: "clock.arrow.circlepath") {
                appModel.selectedTab = .history
            }
            PhotosPicker(selection: $galleryItem, matching: .images) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.figmaCanvas)
                            .frame(width: 48, height: 48)
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                    }
                    .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                    Text(L("common.gallery"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
        .onChange(of: galleryItem) { item in
            guard let item else { return }
            Task {
                if let payload = await GalleryBarcodeScanner.firstQRCodePayload(from: item) {
                    await MainActor.run {
                        scannedAt = Date()
                        scanPayload = payload
                        let info = ScanPayloadClassifier.classify(payload)
                        appModel.addHistory(kind: .scanned, type: info.contentType, payload: info.payloadForDisplay, title: info.titleForHistory)
                        showResult = true
                    }
                }
            }
        }
    }

    private func updateCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { ok in
                DispatchQueue.main.async {
                    isCameraAuthorized = ok
                }
            }
        default:
            isCameraAuthorized = false
        }
    }
}

private struct CameraScannerView: UIViewRepresentable {
    @Binding var isTorchOn: Bool
    let onPayload: (String) -> Void

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = context.coordinator.session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        context.coordinator.configure()
        context.coordinator.start()
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        context.coordinator.setTorch(isOn: isTorchOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPayload: onPayload)
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let session = AVCaptureSession()
        private let output = AVCaptureMetadataOutput()
        private let onPayload: (String) -> Void
        private var isConfigured = false
        private var isLocked = false

        init(onPayload: @escaping (String) -> Void) {
            self.onPayload = onPayload
        }

        func configure() {
            guard !isConfigured else { return }
            session.beginConfiguration()
            session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(for: .video) else {
                session.commitConfiguration()
                return
            }

            guard let input = try? AVCaptureDeviceInput(device: device) else {
                session.commitConfiguration()
                return
            }

            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                if output.availableMetadataObjectTypes.contains(.qr) {
                    output.metadataObjectTypes = [.qr]
                }
            }

            session.commitConfiguration()
            isConfigured = true
        }

        func start() {
            guard !session.isRunning else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }

        func setTorch(isOn: Bool) {
            guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
            guard (try? device.lockForConfiguration()) != nil else { return }
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard !isLocked else { return }
            guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
            guard obj.type == .qr else { return }
            guard let s = obj.stringValue, !s.isEmpty else { return }
            isLocked = true
            onPayload(s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLocked = false
            }
        }
    }
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

private enum GalleryBarcodeScanner {
    static func firstQRCodePayload(from item: PhotosPickerItem) async -> String? {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return nil }
        guard let uiImage = UIImage(data: data) else { return nil }
        guard let cg = uiImage.cgImage else { return nil }

        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        let handler = VNImageRequestHandler(cgImage: cg)
        try? handler.perform([request])
        guard let results = request.results else { return nil }
        return results.first?.payloadStringValue
    }
}

enum ScanPayloadClassifier {
    enum DetectedType {
        case url
        case text
        case email
        case phone
        case wifi
        case contact
    }

    struct Info {
        let contentType: QRContentType
        let detectedType: DetectedType
        let typeName: String
        let kindLabel: String
        let payloadForDisplay: String
        let previewLine: String
        let titleForHistory: String
    }

    static func classify(_ payload: String) -> Info {
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        if lower.hasPrefix("begin:vcard") || lower.hasPrefix("mecard:") {
            let preview = firstLine(from: trimmed)
            return Info(contentType: .contact, detectedType: .contact, typeName: "Contact", kindLabel: "Contact", payloadForDisplay: trimmed, previewLine: preview, titleForHistory: "Contact")
        }
        if lower.hasPrefix("wifi:") {
            let ssid = wifiSSID(from: trimmed) ?? "Wi-Fi Network"
            return Info(contentType: .wifi, detectedType: .wifi, typeName: "Wi-Fi", kindLabel: "Wi-Fi", payloadForDisplay: trimmed, previewLine: ssid, titleForHistory: "WiFi Network")
        }
        if lower.hasPrefix("mailto:") {
            let value = String(trimmed.dropFirst("mailto:".count))
            return Info(contentType: .email, detectedType: .email, typeName: "Email", kindLabel: "Email", payloadForDisplay: value, previewLine: value, titleForHistory: "Email Address")
        }
        if lower.hasPrefix("tel:") {
            let value = String(trimmed.dropFirst("tel:".count))
            return Info(contentType: .contact, detectedType: .phone, typeName: "Phone", kindLabel: "Phone Number", payloadForDisplay: value, previewLine: value, titleForHistory: "Phone Number")
        }
        if let url = normalizedURL(from: trimmed) {
            let host = url.host ?? trimmed
            return Info(contentType: .website, detectedType: .url, typeName: "URL", kindLabel: "Website URL", payloadForDisplay: url.absoluteString, previewLine: host, titleForHistory: "Website Link")
        }
        return Info(contentType: .text, detectedType: .text, typeName: "Text", kindLabel: "Text", payloadForDisplay: trimmed, previewLine: trimmed, titleForHistory: "Text Message")
    }

    private static func normalizedURL(from s: String) -> URL? {
        if let u = URL(string: s), u.scheme != nil { return u }
        if s.contains(".") && !s.contains(" ") {
            return URL(string: "https://\(s)")
        }
        return nil
    }

    private static func firstLine(from s: String) -> String {
        s.components(separatedBy: .newlines).first ?? s
    }

    private static func wifiSSID(from payload: String) -> String? {
        guard let range = payload.range(of: "S:") else { return nil }
        let rest = payload[range.upperBound...]
        guard let end = rest.firstIndex(of: ";") else { return nil }
        return String(rest[..<end])
    }
}

private enum RelativeTimeFormatter {
    static func string(from date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = .current
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }
}

enum ScanResultPresentation {
    case compact
    case full
}

struct ScanResultView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveFlow = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []
    @State private var bannerText: String?
    var presentation: ScanResultPresentation = .full
    var detectedType: ScanPayloadClassifier.DetectedType = .text
    var kindLabel: String = "Website URL"
    var shortUrl: String = "www.example.com/product"
    var fullUrl: String = "https://www.example.com/product/special-offer-2024"
    var scannedAt: String = "Just now"
    var typeName: String = "URL"
    var onDelete: (() -> Void)? = nil
    var onRescan: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Colors.figmaCanvas.ignoresSafeArea()
            VStack(spacing: 0) {
                scanResultHeader
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        scanSuccessBlock
                            .frame(maxWidth: .infinity)
                            .padding(.top, 32)
                        scanResultMainCard
                            .padding(.top, 24)
                        scanResultActionsBlock
                            .padding(.top, 24)
                        scanAnotherButton
                            .padding(.top, 24)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(isPresented: $showSaveFlow) {
            CreateQRFromScanView(initialUrl: fullUrl)
        }
        .sheet(isPresented: $showShare) {
            ActivityView(activityItems: shareItems)
        }
        .overlay(alignment: .top) {
            if let t = bannerText {
                Text(t)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.8))
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var scanResultHeader: some View {
        switch presentation {
        case .compact:
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.Colors.figmaCanvas)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
                Text(L("result.title"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                Spacer(minLength: 0)
                scanResultCloseButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.white)
        case .full:
            HStack(alignment: .center, spacing: 0) {
                Text(L("result.title"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                Spacer(minLength: 0)
                scanResultCloseButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(Color.white)
        }
    }

    private var scanResultCloseButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
                .frame(width: 40, height: 40)
                .background(AppTheme.Colors.figmaCanvas)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var scanSuccessBlock: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.figmaCreateGreen)
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(L("result.success_title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
            Text(L("result.success_subtitle"))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .multilineTextAlignment(.center)
        }
    }

    private var scanResultMainCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.Colors.figmaScanBlue)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "link")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    )
                VStack(alignment: .leading, spacing: 6) {
                    Text(kindLabel)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                    Text(shortUrl)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(24)

            Rectangle()
                .fill(Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255))
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 12) {
                Text(L("result.full_content"))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                Text(fullUrl)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.figmaCanvas)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
            )
            .padding(24)

            Rectangle()
                .fill(Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255))
                .frame(height: 1)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("result.scanned"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                    Text(scannedAt)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(L("result.type"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                    Text(typeName)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                }
            }
            .padding(24)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
    }

    private var scanResultActionsBlock: some View {
        VStack(spacing: 12) {
            Button {
                if let u = URL(string: fullUrl) {
                    UIApplication.shared.open(u)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "safari")
                        .font(.system(size: 18, weight: .medium))
                    Text(L("result.open_link"))
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(AppTheme.Colors.figmaScanBlue)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                scanResultToolTile(systemName: "doc.on.doc", title: L("common.copy")) {
                    UIPasteboard.general.string = fullUrl
                    showBanner(L("common.copied"))
                }
                scanResultToolTile(systemName: "square.and.arrow.up", title: L("common.share")) {
                    if let img = QRCodeGenerator.makeUIImage(payload: fullUrl, colorHex: "#000000", size: 1024) {
                        shareItems = [img]
                        showShare = true
                    } else {
                        shareItems = [fullUrl]
                        showShare = true
                    }
                }
                scanResultToolTile(systemName: "bookmark", title: L("common.save")) { showSaveFlow = true }
            }
            if detectedType == .contact {
                Button {
                    UIPasteboard.general.string = fullUrl
                    showBanner(L("result.contact_copied"))
                } label: {
                    Text(L("result.add_to_contacts"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            if detectedType == .wifi {
                Button {
                    UIPasteboard.general.string = fullUrl
                    showBanner(L("result.wifi_copied"))
                    if let u = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(u)
                    }
                } label: {
                    Text(L("result.connect_wifi"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            if let onDelete {
                Button {
                    onDelete()
                    dismiss()
                } label: {
                    Text("Delete")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 1.0, green: 0.43, blue: 0.43))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func scanResultToolTile(systemName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .frame(height: 28)
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaInk)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var scanAnotherButton: some View {
        Button {
            if let onRescan {
                onRescan()
            } else {
                dismiss()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                Text(L("result.scan_another"))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaInk)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.figmaScanBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func showBanner(_ text: String) {
        bannerText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                bannerText = nil
            }
        }
    }
}

struct CreateQRView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showCreated = false
    @State private var urlValue = "https://example.com"
    @State private var textValue = "Hello world"
    @State private var phoneValue = "+1234567890"
    @State private var emailValue = "hello@example.com"
    @State private var contactName = "John Doe"
    @State private var contactPhone = "+1234567890"
    @State private var contactEmail = "john@example.com"
    @State private var wifiSsid = "Home_WiFi"
    @State private var wifiPassword = "password123"
    @State private var wifiEncryption = "WPA"
    @State private var generatedPayload = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Metrics.sectionSpacing) {
                ScreenHeader(eyebrow: "Create", title: "Generate a QR in seconds", subtitle: "Preset types, simpler editing and a stronger preview card aligned to the rest of the product.")
                
                SectionTitle(title: "Templates", subtitle: "Pick the content type first")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(QRContentType.allCases) { type in
                            Button {
                                appModel.selectedCreationType = type
                            } label: {
                                Text(type.rawValue)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(appModel.selectedCreationType == type ? .white : AppTheme.Colors.ink)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(appModel.selectedCreationType == type ? AppTheme.Colors.brand : AppTheme.Colors.card)
                                    .overlay(
                                        Capsule().stroke(appModel.selectedCreationType == type ? Color.clear : AppTheme.Colors.line, lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                createInputSection
                HeroQRCard(accent: AppTheme.Colors.brand, label: "Preview", title: "Live QR preview", subtitle: "Your selected template and content appear here before saving or sharing.")
                BrandButton(title: "Create QR") {
                    generatedPayload = currentPayload()
                    showCreated = !generatedPayload.isEmpty
                }
                    .padding(.bottom, 28)
            }
            .padding(AppTheme.Metrics.screenPadding)
            .padding(.top, 24)
        }
        .sheet(isPresented: $showCreated) {
            CreateResultView(
                title: appModel.selectedCreationType.rawValue,
                payload: generatedPayload,
                type: appModel.selectedCreationType
            )
        }
    }

    @ViewBuilder
    private var createInputSection: some View {
        switch appModel.selectedCreationType {
        case .website:
            InputCard(title: "Website URL", placeholder: "https://example.com", text: $urlValue)
        case .text:
            InputCard(title: "Text", placeholder: "Enter text", text: $textValue)
        case .phone:
            InputCard(title: "Phone", placeholder: "+1234567890", text: $phoneValue)
        case .email:
            InputCard(title: "Email", placeholder: "name@example.com", text: $emailValue)
        case .contact:
            VStack(spacing: 12) {
                InputCard(title: "Name", placeholder: "John Doe", text: $contactName)
                InputCard(title: "Phone", placeholder: "+1234567890", text: $contactPhone)
                InputCard(title: "Email", placeholder: "john@example.com", text: $contactEmail)
            }
        case .wifi:
            VStack(spacing: 12) {
                InputCard(title: "Network Name", placeholder: "Home_WiFi", text: $wifiSsid)
                InputCard(title: "Password", placeholder: "password123", text: $wifiPassword)
                InputCard(title: "Encryption", placeholder: "WPA / WEP / nopass", text: $wifiEncryption)
            }
        }
    }

    private func currentPayload() -> String {
        switch appModel.selectedCreationType {
        case .website:
            return urlValue.trimmingCharacters(in: .whitespacesAndNewlines)
        case .text:
            return textValue
        case .phone:
            return "tel:\(phoneValue)"
        case .email:
            return "mailto:\(emailValue)"
        case .contact:
            return """
BEGIN:VCARD
VERSION:3.0
FN:\(contactName)
TEL:\(contactPhone)
EMAIL:\(contactEmail)
END:VCARD
"""
        case .wifi:
            return "WIFI:S:\(wifiSsid);T:\(wifiEncryption);P:\(wifiPassword);;"
        }
    }
}

struct CreateResultView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    let title: String
    let payload: String
    let type: QRContentType
    @State private var showShare = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(spacing: 16) {
                        QRCodeImageView(payload: payload, colorHex: "#000000")
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)
                        HeroQRCard(accent: AppTheme.Colors.brand, label: "Created", title: "\(title) QR ready", subtitle: "Save it to My Codes, share it instantly or export later.")
                    }
                    DetailCard(title: "Ready to use", subtitle: "This code is prepared for saving, presenting to others or sending in the next step.", footer: "No issues detected", accent: AppTheme.Colors.brand)
                    HStack(spacing: 12) {
                        BrandButton(title: "Save") {
                            appModel.addMyCode(type: type, payload: payload)
                            appModel.selectedTab = .myCodes
                            dismiss()
                        }
                        BrandButton(title: "Share", filled: false) { showShare = true }
                    }
                }
                .padding(AppTheme.Metrics.screenPadding)
                .padding(.top, 12)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationBarTitle("Create Result", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.Colors.brand)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showShare) {
            if let img = QRCodeGenerator.makeUIImage(payload: payload, colorHex: "#000000", size: 1024) {
                ActivityView(activityItems: [img])
            } else {
                ActivityView(activityItems: [payload])
            }
        }
    }
}

private enum MyCodesFilterChip: String, CaseIterable, Identifiable {
    case all = "All"
    case url = "URL"
    case text = "Text"
    case phone = "Phone"
    case wifi = "WiFi"
    case contact = "Contact"

    var id: String { rawValue }
}

struct MyCodesView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedFilter: MyCodesFilterChip = .all
    @State private var selectedCode: MyQRCodeItem?
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text(L("mycodes.title"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                Spacer(minLength: 0)
                Button {
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.Colors.figmaCanvas)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white)

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MyCodesFilterChip.allCases) { chip in
                            myCodesFilterChip(chip)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                TextField("Search by name", text: $searchText)
                    .font(.system(size: 15, weight: .regular))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)

            if appModel.myCodes.isEmpty {
                myCodesEmptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredMyCodes.isEmpty {
                myCodesFilterEmptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(filteredMyCodes) { item in
                            Button {
                                selectedCode = item
                            } label: {
                                MyCodesGridCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.figmaCanvas.ignoresSafeArea())
        .sheet(item: $selectedCode) { item in
            MyQRCodeDetailView(item: item)
        }
    }

    private var filteredMyCodes: [MyQRCodeItem] {
        let byType: [MyQRCodeItem]
        switch selectedFilter {
        case .all:
            byType = appModel.myCodes
        case .url:
            byType = appModel.myCodes.filter { $0.type == .website }
        case .text:
            byType = appModel.myCodes.filter { $0.type == .text }
        case .phone:
            byType = appModel.myCodes.filter { $0.type == .phone }
        case .wifi:
            byType = appModel.myCodes.filter { $0.type == .wifi }
        case .contact:
            byType = appModel.myCodes.filter { $0.type == .contact }
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return byType }
        return byType.filter { $0.title.lowercased().contains(q) || $0.subtitle.lowercased().contains(q) }
    }

    private func myCodesFilterChip(_ chip: MyCodesFilterChip) -> some View {
        let isOn = selectedFilter == chip
        return Button {
            selectedFilter = chip
        } label: {
            Text(chip.rawValue)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(isOn ? Color.white : AppTheme.Colors.figmaMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(isOn ? AppTheme.Colors.figmaScanBlue : AppTheme.Colors.figmaCanvas)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppTheme.Colors.figmaLine, lineWidth: isOn ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var myCodesEmptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .frame(width: 120, height: 120)
                Image(systemName: "qrcode")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(AppTheme.Colors.figmaTabInactive)
            }
            Text(L("mycodes.empty_title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
                .multilineTextAlignment(.center)
            Text(L("mycodes.empty_subtitle"))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer(minLength: 0)
        }
    }

    private var myCodesFilterEmptyState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)
            Text(L("mycodes.filter_empty_title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
            Text(L("mycodes.filter_empty_subtitle"))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer(minLength: 0)
        }
    }
}

private struct MyCodesGridCard: View {
    let item: MyQRCodeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                .frame(height: 96)
                .overlay(
                    QRCodeImageView(payload: item.payload, colorHex: item.colorHex)
                        .padding(14)
                )
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                )
            HStack(alignment: .center, spacing: 0) {
                Text(item.title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Image(systemName: "ellipsis")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .frame(width: 24, height: 24)
                    .background(AppTheme.Colors.figmaCanvas)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
            }
            .padding(.top, 12)
            Text(item.subtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .lineLimit(1)
                .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
    }
}

private struct MyQRCodeDetailView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    let item: MyQRCodeItem

    @State private var showShare = false
    @State private var shareItems: [Any] = []

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Colors.figmaCanvas.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text(item.title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaInk)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.Colors.figmaCanvas)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            QRCodeImageView(payload: item.payload, colorHex: item.colorHex)
                                .frame(width: 240, height: 240)
                                .padding(.top, 18)
                            Text(item.subtitle)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(AppTheme.Colors.figmaMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 18)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                        )

                        HStack(spacing: 12) {
                            Button {
                                UIPasteboard.general.string = item.payload
                            } label: {
                                Text("Copy")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(AppTheme.Colors.figmaScanBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            Button {
                                if let img = QRCodeGenerator.makeUIImage(payload: item.payload, colorHex: item.colorHex, size: 1024) {
                                    shareItems = [img]
                                    showShare = true
                                } else {
                                    shareItems = [item.payload]
                                    showShare = true
                                }
                            } label: {
                                Text("Share")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.figmaInk)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            appModel.deleteMyCode(id: item.id)
                            dismiss()
                        } label: {
                            Text("Delete")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 1.0, green: 0.43, blue: 0.43))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showShare) {
            ActivityView(activityItems: shareItems)
        }
    }
}

private struct QRCodeImageView: View {
    let payload: String
    let colorHex: String?

    var body: some View {
        if let img = QRCodeGenerator.makeUIImage(payload: payload, colorHex: colorHex, size: 512) {
            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: 42, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaTabInactive)
        }
    }
}

private enum QRCodeGenerator {
    static func makeUIImage(payload: String, colorHex: String?, size: CGFloat) -> UIImage? {
        guard let data = payload.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard var output = filter.outputImage else { return nil }

        if let hex = colorHex, let tint = UIColor(hex: hex) {
            if let colorFilter = CIFilter(name: "CIFalseColor") {
                colorFilter.setValue(output, forKey: kCIInputImageKey)
                colorFilter.setValue(CIColor(color: tint), forKey: "inputColor0")
                colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
                if let colored = colorFilter.outputImage {
                    output = colored
                }
            }
        }

        let scale = max(1, floor(size / output.extent.width))
        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext(options: nil)
        guard let cg = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6 else { return nil }
        let rStr = String(s.prefix(2))
        let gStr = String(s.dropFirst(2).prefix(2))
        let bStr = String(s.dropFirst(4).prefix(2))
        guard
            let r = UInt8(rStr, radix: 16),
            let g = UInt8(gStr, radix: 16),
            let b = UInt8(bStr, radix: 16)
        else { return nil }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
}

private enum CreateQRFromScanContentType: String, CaseIterable, Identifiable {
    case url = "URL"
    case text = "Text"
    case contact = "Contact"
    case wifi = "Wi-Fi"

    var id: String { rawValue }
}

struct CreateQRFromScanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedType: CreateQRFromScanContentType = .url
    @State private var urlText: String
    @State private var selectedColorIndex: Int = 1

    init(initialUrl: String) {
        _urlText = State(initialValue: initialUrl)
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.figmaCanvas.ignoresSafeArea()
            VStack(spacing: 0) {
                createFromScanHeader
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        createFromScanContentType
                            .padding(.top, 17.5)
                        createFromScanInput
                            .padding(.top, 17.5)
                        createFromScanDesignOptions
                            .padding(.top, 17.5)
                        createFromScanGenerateButton
                            .padding(.top, 18)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    private var createFromScanHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(L("create.title"))
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
            Spacer(minLength: 0)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.Colors.figmaCanvas)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    private var createFromScanContentType: some View {
        VStack(alignment: .leading, spacing: 15.5) {
            Text(L("create.content_type"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)

            HStack(spacing: 8) {
                createFromScanTypeTile(.url, systemName: "link")
                createFromScanTypeTile(.text, systemName: "textformat")
                createFromScanTypeTile(.contact, systemName: "person.crop.circle")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                selectedType = .wifi
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "wifi")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                    Text("Wi-Fi")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 49)
                .padding(.horizontal, 16)
                .background(AppTheme.Colors.figmaCanvas)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func createFromScanTypeTile(_ type: CreateQRFromScanContentType, systemName: String) -> some View {
        let isOn = selectedType == type
        return Button {
            selectedType = type
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isOn ? AppTheme.Colors.figmaInk : AppTheme.Colors.figmaMuted)
                Text(type.rawValue)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(isOn ? AppTheme.Colors.figmaInk : AppTheme.Colors.figmaMuted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 71)
            .background(isOn ? Color.white : AppTheme.Colors.figmaCanvas)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isOn ? AppTheme.Colors.figmaLine : Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(width: 105, height: 71)
    }

    private var createFromScanInput: some View {
        VStack(alignment: .leading, spacing: 12.5) {
            Text(L("create.website_url"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)

            HStack(spacing: 12) {
                TextField("https://example.com", text: $urlText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                Image(systemName: "link")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.Colors.figmaTabInactive)
            }
            .padding(.horizontal, 16)
            .frame(height: 59.5)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255), lineWidth: 1)
            )
        }
    }

    private var createFromScanDesignOptions: some View {
        VStack(alignment: .leading, spacing: 15.5) {
            Text(L("create.design_options"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Text(L("create.color"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                    Spacer(minLength: 0)
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { idx in
                            Button {
                                selectedColorIndex = idx
                            } label: {
                                Circle()
                                    .fill(colorForIndex(idx))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle().stroke(Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255), lineWidth: 1)
                                    )
                                    .overlay(
                                        Circle().stroke(AppTheme.Colors.figmaInk.opacity(selectedColorIndex == idx ? 0.35 : 0), lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                HStack(spacing: 12) {
                    Text(L("create.add_logo"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                    Spacer(minLength: 0)
                    Text(L("create.pro_feature"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(red: 227 / 255, green: 227 / 255, blue: 227 / 255), lineWidth: 1)
            )
        }
    }

    private func colorForIndex(_ idx: Int) -> Color {
        switch idx {
        case 0: return Color.black
        case 1: return AppTheme.Colors.figmaScanBlue
        case 2: return AppTheme.Colors.figmaCreateGreen
        default: return AppTheme.Colors.figmaMyOrange
        }
    }

    private var createFromScanGenerateButton: some View {
        Button {
            appModel.addMyCode(type: .website, payload: urlText, title: "My Website", subtitle: subtitleForSave(), colorHex: colorHexForSave())
            appModel.selectedTab = .myCodes
            dismiss()
        } label: {
            Text(L("create.generate"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(AppTheme.Colors.figmaScanBlue)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func subtitleForSave() -> String {
        if let u = URL(string: urlText), let host = u.host { return host }
        return urlText
    }

    private func colorHexForSave() -> String? {
        switch selectedColorIndex {
        case 0: return "#000000"
        case 1: return "#7ACBFF"
        case 2: return "#77C97E"
        case 3: return "#FFB86C"
        default: return nil
        }
    }
}

private enum HistoryFilterChip: String, CaseIterable, Identifiable {
    case all = "All"
    case scanned = "Scanned"
    case created = "Created"

    var id: String { rawValue }
}

struct HistoryView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedFilter: HistoryFilterChip = .all
    @State private var showActions = false
    @State private var showClearConfirm = false
    @State private var selectedItem: QRHistoryItem?
    @State private var showShare = false
    @State private var shareItems: [Any] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text(L("common.history"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                Spacer(minLength: 0)
                Button {
                    showActions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.Colors.figmaCanvas)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white)

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(HistoryFilterChip.allCases) { chip in
                            historyFilterChipButton(chip)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)

            if appModel.history.isEmpty {
                historyEmptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredHistory.isEmpty {
                historyFilterEmptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(filteredHistory) { item in
                            HistoryFigmaRow(
                                item: item,
                                onOpen: { selectedItem = item },
                                onShare: {
                                    shareItems = [item.payload]
                                    showShare = true
                                },
                                onDelete: { appModel.deleteHistory(id: item.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.figmaCanvas.ignoresSafeArea())
        .confirmationDialog(L("common.history"), isPresented: $showActions, titleVisibility: .visible) {
            Button(L("history.clear_all"), role: .destructive) { showClearConfirm = true }
            Button(L("common.cancel"), role: .cancel) {}
        }
        .confirmationDialog(L("history.clear_confirm"), isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button(L("history.clear_all"), role: .destructive) { appModel.clearHistory() }
            Button(L("common.cancel"), role: .cancel) {}
        }
        .sheet(item: $selectedItem) { item in
            let info = ScanPayloadClassifier.classify(item.payload)
            ScanResultView(
                presentation: .full,
                detectedType: info.detectedType,
                kindLabel: info.kindLabel,
                shortUrl: info.previewLine,
                fullUrl: info.payloadForDisplay,
                scannedAt: RelativeTimeFormatter.string(from: item.createdAt),
                typeName: info.typeName,
                onDelete: { appModel.deleteHistory(id: item.id) },
                onRescan: {
                    selectedItem = nil
                    appModel.selectedTab = .scan
                }
            )
        }
        .sheet(isPresented: $showShare) {
            ActivityView(activityItems: shareItems)
        }
    }

    private var filteredHistory: [QRHistoryItem] {
        switch selectedFilter {
        case .all:
            return appModel.history
        case .scanned:
            return appModel.history.filter { $0.kind == .scanned }
        case .created:
            return appModel.history.filter { $0.kind == .created }
        }
    }

    private func historyFilterChipButton(_ chip: HistoryFilterChip) -> some View {
        let isOn = selectedFilter == chip
        return Button {
            selectedFilter = chip
        } label: {
            Text(chip.rawValue)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(isOn ? Color.white : AppTheme.Colors.figmaMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(isOn ? AppTheme.Colors.figmaScanBlue : AppTheme.Colors.figmaCanvas)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppTheme.Colors.figmaLine, lineWidth: isOn ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var historyEmptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.Colors.figmaLine, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .frame(width: 120, height: 120)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(AppTheme.Colors.figmaTabInactive)
            }
            Text(L("history.empty_title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
                .multilineTextAlignment(.center)
            Text(L("history.empty_subtitle"))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer(minLength: 0)
        }
    }

    private var historyFilterEmptyState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)
            Text(L("history.filter_empty_title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
            Text(L("history.filter_empty_subtitle"))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer(minLength: 0)
        }
    }
}

private struct HistoryFigmaRow: View {
    let item: QRHistoryItem
    let onOpen: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    private var accentColor: Color {
        item.kind == .scanned ? AppTheme.Colors.figmaScanBlue : AppTheme.Colors.figmaCreateGreen
    }

    private var metaPrefix: String {
        item.kind == .scanned ? "Scanned" : "Created"
    }

    var body: some View {
        Button {
            onOpen()
        } label: {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 48, height: 48)
                    Image(systemName: "qrcode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .lineLimit(2)
                    Text(item.payload)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .lineLimit(2)
                    Text("\(metaPrefix) • \(formattedTime(item.createdAt))")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaTabInactive)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 8) {
                    Button {
                        onShare()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.Colors.figmaCanvas)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.Colors.figmaCanvas)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct PaywallView: View {
    @EnvironmentObject private var appModel: AppModel
    let source: PaywallSource
    
    init(source: PaywallSource = .feature) {
        self.source = source
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Metrics.sectionSpacing) {
                    HStack {
                        Spacer()
                        Button(action: { appModel.closePaywall() }) {
                            Text("Later")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppTheme.Colors.secondaryInk)
                        }
                    }
                    ScreenHeader(eyebrow: source == .onboarding ? "Start stronger" : "Upgrade", title: "Go Premium for the full toolkit", subtitle: "Unlimited scans, all creation presets, saved collections and quicker export actions in a more complete flow.")
                    HeroQRCard(accent: AppTheme.Colors.warning, label: "Premium", title: "Unlock the full set", subtitle: "Fewer limits, cleaner access to all templates and stronger daily usage for people who scan often.")
                    VStack(spacing: 14) {
                        paywallFeature("Unlimited QR scans")
                        paywallFeature("All creation templates")
                        paywallFeature("Saved code collections")
                        paywallFeature("Fast export actions")
                    }
                    DetailCard(title: "Weekly plan", subtitle: "$4.99 / week after trial. Cancel anytime from your App Store subscriptions.", footer: "Best for heavy usage", accent: AppTheme.Colors.warning)
                }
                .padding(AppTheme.Metrics.screenPadding)
                .padding(.top, 24)
            }
            
            VStack(spacing: 12) {
                BrandButton(title: "Start for $4.99 / week") { appModel.activatePremium() }
                BrandButton(title: "Restore Purchase", filled: false) { appModel.closePaywall() }
            }
            .padding(.horizontal, AppTheme.Metrics.screenPadding)
            .padding(.top, 10)
            .padding(.bottom, 26)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
    
    private func paywallFeature(_ text: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.Colors.warningSoft)
                .frame(width: 36, height: 36)
                .overlay(Circle().fill(AppTheme.Colors.warning).frame(width: 12, height: 12))
            Text(text)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(AppTheme.Colors.ink)
            Spacer()
        }
        .padding(18)
        .appCardStyle(radius: 24)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var webGate: QRWebGate

    var body: some View {
        ZStack {
            AppTheme.Colors.figmaCanvas.ignoresSafeArea()
            VStack(spacing: 0) {
                settingsHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                Button {
                    webGate.showPrivacySheet = true
                } label: {
                    HStack {
                        Text(L("settings.privacy_policy"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaInk)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer(minLength: 0)
            }
        }
    }

    private var settingsHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                appModel.closeSettings()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(L("settings.title"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 40, height: 40)
        }
        .frame(maxWidth: .infinity)
    }
}

private enum PricingPlan: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }
}

struct PricingView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var integrations: AppIntegrationService
    @State private var selectedPlan: PricingPlan = .monthly

    var body: some View {
        ZStack {
            AppTheme.Colors.figmaCanvas.ignoresSafeArea()
            pricingBackdrop
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    pricingHeader
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    pricingHero
                        .padding(.top, 20)

                    pricingFeatures
                        .padding(.top, 32)
                        .padding(.horizontal, 24)

                    pricingPlans
                        .padding(.top, 32)
                        .padding(.horizontal, 24)

                    pricingContinue
                        .padding(.top, 32)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)
                }
            }
        }
    }

    private var pricingBackdrop: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.figmaScanBlue)
                    .frame(width: 74, height: 74)
                    .position(x: -40 + 37, y: 146 + 37)
                Circle()
                    .fill(AppTheme.Colors.figmaMyOrange)
                    .frame(width: 87, height: 87)
                    .position(x: 264 + 43.5, y: 114 + 43.5)
                Circle()
                    .fill(AppTheme.Colors.figmaCreateGreen)
                    .frame(width: 128, height: 128)
                    .position(x: -27 + 64, y: 301 + 64)
                Circle()
                    .fill(AppTheme.Colors.figmaScanBlue)
                    .frame(width: 74, height: 74)
                    .position(x: 324 + 37, y: 237 + 37)
                Circle()
                    .fill(AppTheme.Colors.figmaMyOrange)
                    .frame(width: 87, height: 87)
                    .position(x: 296 + 43.5, y: 410 + 43.5)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var pricingHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                appModel.closePaywall()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppTheme.Colors.figmaLine, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button {
                Task { await integrations.restorePurchases() }
            } label: {
                Text(L("pricing.restore"))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var pricingHero: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .frame(width: 217, height: 217)
                .overlay(
                    PricingCreateQRIcon()
                        .frame(width: 166, height: 165)
                        .frame(width: 170, height: 170)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                )

            Text("Unlock Full QR\nTools")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(AppTheme.Colors.figmaInk)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("Unlimited scans, custom QR creation, and full\nhistory access.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }

    private var pricingFeatures: some View {
        VStack(spacing: 16) {
            pricingFeatureRow(
                color: AppTheme.Colors.figmaScanBlue,
                systemName: "viewfinder",
                title: "Unlimited QR Scans",
                subtitleLine1: "Scan as many QR codes as you",
                subtitleLine2: "want"
            )
            pricingFeatureRow(
                color: AppTheme.Colors.figmaScanBlue,
                systemName: "qrcode",
                title: "Create All QR Types",
                subtitleLine1: "URL, Text, Contact, WiFi, and",
                subtitleLine2: "more"
            )
            pricingFeatureRow(
                color: AppTheme.Colors.figmaScanBlue,
                systemName: "nosign",
                title: "No Ads",
                subtitleLine1: "Clean, distraction-free",
                subtitleLine2: "experience"
            )
            pricingFeatureRow(
                color: AppTheme.Colors.figmaScanBlue,
                systemName: "icloud",
                title: "Cloud Backup",
                subtitleLine1: "Sync across all your devices",
                subtitleLine2: nil
            )
            pricingFeatureRow(
                color: AppTheme.Colors.figmaScanBlue,
                systemName: "chart.bar",
                title: "Advanced Analytics",
                subtitleLine1: "Track scans and usage patterns",
                subtitleLine2: nil
            )
        }
    }

    private func pricingFeatureRow(
        color: Color,
        systemName: String,
        title: String,
        subtitleLine1: String,
        subtitleLine2: String?
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: systemName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                if let subtitleLine2 {
                    Text("\(subtitleLine1)\n\(subtitleLine2)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(subtitleLine1)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
        )
    }

    private var pricingPlans: some View {
        VStack(spacing: 16) {
            pricingPlanCardWeekly
            pricingPlanCardMonthly
            pricingPlanCardYearly
        }
    }

    private var pricingPlanCardWeekly: some View {
        Button {
            selectedPlan = .weekly
        } label: {
            ZStack(alignment: .top) {
                VStack(spacing: 8) {
                    Text(offerTitle(.weekly, fallback: "Weekly Plan"))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .padding(.top, 26)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(offerPrice(.weekly, fallback: "$3.99"))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaInk)
                        Text(offerPeriod(.weekly, fallback: "/ week"))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                    }

                    Text("3-day free trial")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .padding(.top, 8)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 173.5)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                )

                Text("MOST POPULAR")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.figmaScanBlue)
                    .clipShape(Capsule())
                    .offset(y: -12)
            }
        }
        .buttonStyle(.plain)
    }

    private var pricingPlanCardMonthly: some View {
        Button {
            selectedPlan = .monthly
        } label: {
            VStack(spacing: 8) {
                Text(offerTitle(.monthly, fallback: "Monthly Plan"))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.figmaInk)
                    .padding(.top, 24)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(offerPrice(.monthly, fallback: "$7.99"))
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                    Text(offerPeriod(.monthly, fallback: "/ month"))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                }

                Text("Cancel anytime")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .padding(.top, 8)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 169.5)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selectedPlan == .monthly ? AppTheme.Colors.figmaScanBlue : AppTheme.Colors.figmaLine, lineWidth: selectedPlan == .monthly ? 1 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var pricingPlanCardYearly: some View {
        Button {
            selectedPlan = .yearly
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Text(offerTitle(.yearly, fallback: "Yearly Plan"))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.figmaInk)
                        .padding(.top, 24)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(offerPrice(.yearly, fallback: "$29.99"))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.figmaInk)
                        Text(offerPeriod(.yearly, fallback: "/ year"))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(AppTheme.Colors.figmaMuted)
                    }

                    HStack(alignment: .center, spacing: 10) {
                        Text("$99.99")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(AppTheme.Colors.figmaTabInactive)
                            .strikethrough()
                        Text("Save $70")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(AppTheme.Colors.figmaCreateGreen)
                    }
                    .padding(.top, 6)

                    Text("Best value option")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                        .padding(.top, 8)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.Colors.figmaLine, lineWidth: 1)
                )

                Text("SAVE 70%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.figmaCreateGreen)
                    .clipShape(Capsule())
                    .padding(.trailing, 16)
                    .offset(y: -12)
            }
        }
        .buttonStyle(.plain)
    }

    private var pricingContinue: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await integrations.purchase(plan: selectedPlan.asSubscriptionPlan)
                    if integrations.hasActiveSubscription {
                        appModel.activatePremium()
                    }
                }
            } label: {
                Text(L("pricing.continue"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(AppTheme.Colors.figmaScanBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(integrations.isPurchasing)

            Text(L("pricing.renewable"))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.figmaMuted)

            HStack(spacing: 12) {
                Button { } label: {
                    Text(L("pricing.terms"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                }
                .buttonStyle(.plain)
                Text("•")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                Button { } label: {
                    Text(L("pricing.privacy"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.Colors.figmaMuted)
                }
                .buttonStyle(.plain)
            }

            if let e = integrations.purchaseErrorText, !e.isEmpty {
                Text(e)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.Colors.figmaMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
    }

    private func offerTitle(_ plan: PricingPlan, fallback: String) -> String {
        integrations.offers.first(where: { $0.id == plan.asSubscriptionPlan })?.title ?? fallback
    }

    private func offerPrice(_ plan: PricingPlan, fallback: String) -> String {
        integrations.offers.first(where: { $0.id == plan.asSubscriptionPlan })?.priceText ?? fallback
    }

    private func offerPeriod(_ plan: PricingPlan, fallback: String) -> String {
        integrations.offers.first(where: { $0.id == plan.asSubscriptionPlan })?.periodText ?? fallback
    }

}

private extension PricingPlan {
    var asSubscriptionPlan: SubscriptionPlan {
        switch self {
        case .weekly: return .weekly
        case .monthly: return .monthly
        case .yearly: return .yearly
        }
    }
}

private struct PricingCreateQRIcon: View {
    private let fill = Color(red: 0x7A / 255, green: 0xCB / 255, blue: 0xFF / 255)

    private let viewBox = CGSize(width: 166, height: 165)

    private let paths: [String] = [
        "M51.3566 7.80766C51.3566 3.49561 47.861 0 43.5489 0H7.80766C3.49561 0 0 3.49561 0 7.80766V43.5489C0 47.861 3.49561 51.3566 7.80766 51.3566H43.5489C47.861 51.3566 51.3566 47.861 51.3566 43.5489V7.80766ZM41.0863 33.2773C41.0863 37.5894 37.5907 41.085 33.2787 41.085H18.0806C13.7685 41.085 10.2729 37.5894 10.2729 33.2773V18.0792C10.2729 13.7672 13.7685 10.2716 18.0806 10.2716H33.2787C37.5907 10.2716 41.0863 13.7672 41.0863 18.0792V33.2773Z",
        "M19.4028 26.2492C19.4028 29.4006 21.9575 31.9553 25.1089 31.9553C28.2603 31.9553 30.815 29.4006 30.815 26.2492C30.815 23.0978 28.2603 20.5432 25.1089 20.5432C21.9575 20.5432 19.4028 23.0978 19.4028 26.2492Z",
        "M164.34 7.80766C164.34 3.49561 160.844 0 156.532 0H120.791C116.479 0 112.983 3.49561 112.983 7.80766V43.5489C112.983 47.861 116.479 51.3566 120.791 51.3566H156.532C160.844 51.3566 164.34 47.861 164.34 43.5489V7.80766ZM154.07 33.2773C154.07 37.5894 150.574 41.085 146.262 41.085H131.064C126.752 41.085 123.256 37.5894 123.256 33.2773V18.0792C123.256 13.7672 126.752 10.2716 131.064 10.2716H146.262C150.574 10.2716 154.07 13.7672 154.07 18.0792V33.2773Z",
        "M132.386 26.2492C132.386 29.4006 134.94 31.9553 138.092 31.9553C141.243 31.9553 143.798 29.4006 143.798 26.2492C143.798 23.0978 141.243 20.5432 138.092 20.5432C134.94 20.5432 132.386 23.0978 132.386 26.2492Z",
        "M0.00146484 156.532C0.00146484 160.844 3.49707 164.34 7.80912 164.34H43.5504C47.8624 164.34 51.3581 160.844 51.3581 156.532V120.791C51.3581 116.479 47.8624 112.983 43.5504 112.983H7.80912C3.49707 112.983 0.00146484 116.479 0.00146484 120.791V156.532ZM10.273 131.063C10.273 126.751 13.7686 123.255 18.0807 123.255H33.2788C37.5908 123.255 41.0865 126.751 41.0865 131.063V146.261C41.0865 150.573 37.5908 154.068 33.2788 154.068H18.0807C13.7686 154.068 10.273 150.573 10.273 146.261V131.063Z",
        "M19.4028 139.233C19.4028 142.384 21.9575 144.939 25.1089 144.939C28.2603 144.939 30.815 142.384 30.815 139.233C30.815 136.081 28.2603 133.527 25.1089 133.527C21.9575 133.527 19.4028 136.081 19.4028 139.233Z",
        "M82.1716 46.7917C82.1716 44.2706 84.2153 42.2269 86.7364 42.2269H87.3067C90.1428 42.2269 92.4418 39.9278 92.4418 37.0917V35.9486C92.4418 33.1125 90.1428 30.8134 87.3067 30.8134C84.4707 30.8134 82.1716 28.5143 82.1716 25.6783V15.4073C82.1716 12.5709 79.8722 10.2716 77.0358 10.2716C74.1994 10.2716 71.9 7.9722 71.9 5.13578C71.9 2.29937 69.6006 0 66.7642 0C63.9278 0 61.6284 2.29938 61.6284 5.1358V15.4074C61.6284 18.2438 63.9281 20.5432 66.7646 20.5432C69.6006 20.5432 71.9 22.8422 71.9 25.6783C71.9 28.5143 69.6006 30.8134 66.7646 30.8134C63.9281 30.8134 61.6284 33.1128 61.6284 35.9492V37.0911C61.6284 39.9275 63.9278 42.2269 66.7642 42.2269H67.3352C69.8563 42.2269 71.9 44.2706 71.9 46.7917C71.9 49.3128 73.9438 51.3566 76.4649 51.3566H77.6067C80.1278 51.3566 82.1716 49.3128 82.1716 46.7917Z",
        "M66.7642 71.8983C69.6007 71.8983 71.9 69.5989 71.9 66.7625V56.4923C71.9 53.6559 69.6003 51.3565 66.7639 51.3565C63.9279 51.3565 61.6284 53.6555 61.6284 56.4916C61.6284 59.3276 59.3294 61.6267 56.4933 61.6267H43.1876C38.8755 61.6267 35.3799 65.1223 35.3799 69.4344V74.7516C35.3799 78.8486 32.0587 82.1699 27.9617 82.1699H25.6793C22.8428 82.1699 20.5435 84.4692 20.5435 87.3057C20.5435 90.1421 22.8428 92.4415 25.6793 92.4415H45.0806C47.917 92.4415 50.2164 90.1421 50.2164 87.3057C50.2164 84.4692 52.5157 82.1699 55.3522 82.1699H56.4927C59.3291 82.1699 61.6284 79.8705 61.6284 77.0341C61.6284 74.1977 63.9278 71.8983 66.7642 71.8983Z",
        "M25.6803 61.6268H15.4088C12.5723 61.6268 10.2729 63.9261 10.2729 66.7626C10.2729 69.599 12.5723 71.8984 15.4088 71.8984H25.6803C28.5167 71.8984 30.8161 69.599 30.8161 66.7626C30.8161 63.9261 28.5167 61.6268 25.6803 61.6268Z",
        "M14.2676 102.712C17.1037 102.712 19.4028 100.413 19.4028 97.5767V97.0064C19.4028 94.4853 17.359 92.4416 14.8379 92.4416C12.3168 92.4416 10.273 90.3978 10.273 87.8767V77.0342C10.273 74.1978 7.97366 71.8984 5.13725 71.8984C2.30083 71.8984 0.00146484 74.1978 0.00146484 77.0342V92.4416V94.9042C0.00146484 99.2162 3.49707 102.712 7.80912 102.712H10.273H14.2676Z",
        "M61.6284 118.119C61.6284 120.956 63.9278 123.255 66.7642 123.255C69.6006 123.255 71.9 120.956 71.9 118.119C71.9 115.283 69.6006 112.983 66.7642 112.983C63.9278 112.983 61.6284 115.283 61.6284 118.119Z",
        "M138.663 82.17C135.826 82.17 133.527 79.8706 133.527 77.0342C133.527 74.1978 131.227 71.8984 128.391 71.8984C125.555 71.8984 123.255 74.1978 123.255 77.0342V82.17V84.6339C123.255 88.946 119.76 92.4416 115.448 92.4416H107.849C105.012 92.4416 102.713 94.7406 102.713 97.5767C102.713 100.413 105.012 102.712 107.849 102.712H123.255H128.392C131.228 102.712 133.527 100.413 133.527 97.5767C133.527 94.7406 135.826 92.4416 138.662 92.4416C141.499 92.4416 143.798 90.1422 143.798 87.3058C143.798 84.4693 141.499 82.17 138.663 82.17Z",
        "M61.6285 87.3057C61.6285 90.1421 59.3288 92.4415 56.4924 92.4415C53.6563 92.4415 51.3569 94.7406 51.3569 97.5767C51.3569 100.413 53.656 102.712 56.4921 102.712H82.7419C85.578 102.712 87.8771 100.413 87.8771 97.5767V95.2942C87.8771 93.7187 86.5999 92.4415 85.0244 92.4415C83.4489 92.4415 82.1717 91.1643 82.1717 89.5888V87.3057C82.1717 84.4693 79.8723 82.1699 77.0359 82.1699H66.7643C63.9279 82.1699 61.6285 84.4693 61.6285 87.3057Z",
        "M159.776 61.6268C156.625 61.6268 154.07 64.1814 154.07 67.3328V87.3057C154.07 90.1421 151.77 92.4415 148.934 92.4415C146.098 92.4415 143.798 94.7406 143.798 97.5767C143.798 100.413 146.097 102.712 148.933 102.712H154.07H157.674C161.986 102.712 165.482 99.2162 165.482 94.9041V92.4415V67.3328C165.482 64.1814 162.927 61.6268 159.776 61.6268Z",
        "M92.4418 118.12C92.4418 120.956 90.1428 123.255 87.3067 123.255C84.4707 123.255 82.1716 125.555 82.1716 128.391C82.1716 131.227 84.4707 133.527 87.3067 133.527C90.1428 133.527 92.4418 135.826 92.4418 138.662V143.797V148.933C92.4418 151.769 90.1428 154.068 87.3067 154.068C84.4707 154.068 82.1716 151.769 82.1716 148.933V143.797V141.334C82.1716 137.022 78.676 133.527 74.3639 133.527H66.7636C63.9275 133.527 61.6284 135.826 61.6284 138.662C61.6284 141.498 63.9278 143.797 66.7639 143.797C69.6003 143.797 71.9 146.096 71.9 148.933C71.9 151.769 69.6006 154.068 66.7642 154.068C63.9278 154.068 61.6284 156.368 61.6284 159.204C61.6284 162.041 63.9278 164.34 66.7642 164.34H138.663C141.499 164.34 143.798 162.041 143.798 159.204C143.798 156.368 141.499 154.068 138.663 154.068C135.826 154.068 133.527 151.769 133.527 148.933C133.527 146.096 135.826 143.797 138.663 143.797C141.499 143.797 143.798 146.096 143.798 148.933C143.798 151.769 146.098 154.068 148.934 154.068C151.771 154.068 154.07 156.368 154.07 159.204C154.07 162.041 156.369 164.34 159.206 164.34H159.776C162.927 164.34 165.482 161.785 165.482 158.634V143.797V133.527V127.819C165.482 124.668 162.927 122.113 159.776 122.113H158.635C156.114 122.113 154.07 120.069 154.07 117.548C154.07 115.027 152.026 112.983 149.505 112.983H148.934C146.098 112.983 143.798 115.283 143.798 118.119C143.798 120.956 146.098 123.255 148.934 123.255C151.771 123.255 154.07 125.554 154.07 128.391C154.07 131.227 151.771 133.527 148.934 133.527H141.334C137.022 133.527 133.527 130.031 133.527 125.719V118.689C133.527 115.538 130.972 112.983 127.821 112.983C124.669 112.983 122.115 115.538 122.115 118.689V146.261C122.115 150.573 118.619 154.068 114.307 154.068H107.849C105.013 154.068 102.713 151.769 102.713 148.933C102.713 146.096 105.013 143.797 107.85 143.797C110.686 143.797 112.985 141.498 112.985 138.662C112.985 135.826 110.686 133.527 107.85 133.527C105.013 133.527 102.713 131.227 102.713 128.391C102.713 125.554 105.013 123.255 107.849 123.255C110.686 123.255 112.985 120.956 112.985 118.119C112.985 115.283 110.686 112.983 107.849 112.983C105.013 112.983 102.713 110.684 102.713 107.848C102.713 105.011 100.414 102.712 97.5777 102.712C94.7412 102.712 92.4418 105.011 92.4418 107.848V118.12Z",
        "M103.855 61.6282C103.855 58.4765 101.3 55.9215 98.1484 55.9215C94.9966 55.9215 92.4416 58.4765 92.4416 61.6282V66.7633C92.4416 69.5994 90.1426 71.8984 87.3065 71.8984C84.4705 71.8984 82.1714 74.1982 82.1714 77.0342C82.1714 79.8703 84.4705 82.17 87.3065 82.17H89.5889C91.1644 82.17 92.4416 83.4472 92.4416 85.0227C92.4416 86.5982 93.7188 87.8754 95.2944 87.8754H101.002C102.578 87.8754 103.855 86.5982 103.855 85.0227C103.855 83.4472 105.132 82.17 106.708 82.17H108.42C110.941 82.17 112.985 80.1263 112.985 77.6052V76.4633C112.985 73.9422 110.941 71.8984 108.42 71.8984C105.899 71.8984 103.855 69.8547 103.855 67.3336V61.6282Z",
        "M133.527 66.7626C133.527 69.599 135.826 71.8984 138.663 71.8984C141.499 71.8984 143.798 69.599 143.798 66.7626C143.798 63.9261 141.499 61.6268 138.663 61.6268C135.826 61.6268 133.527 63.9261 133.527 66.7626Z",
        "M112.985 66.7626C112.985 69.599 115.284 71.8984 118.121 71.8984C120.957 71.8984 123.256 69.599 123.256 66.7626C123.256 63.9261 120.957 61.6268 118.121 61.6268C115.284 61.6268 112.985 63.9261 112.985 66.7626Z",
        "M102.713 25.6776V15.4073C102.713 12.5709 100.414 10.2715 97.5777 10.2715C94.7413 10.2715 92.4419 12.5709 92.4419 15.4073V25.6776C92.4419 28.514 94.7413 30.8134 97.5777 30.8134C100.414 30.8134 102.713 28.514 102.713 25.6776Z",
        "M82.1714 5.13578C82.1714 7.9722 84.4708 10.2716 87.3072 10.2716C90.1436 10.2716 92.443 7.9722 92.443 5.13578C92.443 2.29937 90.1436 0 87.3072 0C84.4708 0 82.1714 2.29937 82.1714 5.13578Z"
    ]

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / viewBox.width
            let sy = geo.size.height / viewBox.height
            let scale = min(sx, sy)
            let w = viewBox.width * scale
            let h = viewBox.height * scale
            let dx = (geo.size.width - w) * 0.5
            let dy = (geo.size.height - h) * 0.5

            Canvas { ctx, _ in
                ctx.translateBy(x: dx, y: dy)
                ctx.scaleBy(x: scale, y: scale)
                for d in paths {
                    if let path = SVGPathParser.path(from: d) {
                        ctx.fill(path, with: .color(fill))
                    }
                }
            }
        }
    }
}

private enum SVGPathParser {
    static func path(from d: String) -> Path? {
        var s = d
        s = s.replacingOccurrences(of: ",", with: " ")
        s = s.replacingOccurrences(of: "-", with: " -")
        s = s.replacingOccurrences(of: "\n", with: " ")
        s = s.replacingOccurrences(of: "\t", with: " ")

        var tokens: [String] = []
        var cur = ""
        for ch in s {
            if ch.isLetter {
                if !cur.isEmpty { tokens.append(cur); cur = "" }
                tokens.append(String(ch))
            } else if ch == " " {
                if !cur.isEmpty { tokens.append(cur); cur = "" }
            } else {
                cur.append(ch)
            }
        }
        if !cur.isEmpty { tokens.append(cur) }

        func nextNumber(_ i: inout Int) -> CGFloat? {
            guard i < tokens.count else { return nil }
            let t = tokens[i]
            guard !t.isEmpty, !t.first!.isLetter else { return nil }
            i += 1
            return CGFloat(Double(t) ?? 0)
        }

        var i = 0
        var p = Path()
        var current = CGPoint.zero
        var start = CGPoint.zero

        while i < tokens.count {
            let cmd = tokens[i]
            i += 1
            switch cmd {
            case "M":
                guard let x = nextNumber(&i), let y = nextNumber(&i) else { return nil }
                current = CGPoint(x: x, y: y)
                start = current
                p.move(to: current)
            case "H":
                guard let x = nextNumber(&i) else { return nil }
                current = CGPoint(x: x, y: current.y)
                p.addLine(to: current)
            case "V":
                guard let y = nextNumber(&i) else { return nil }
                current = CGPoint(x: current.x, y: y)
                p.addLine(to: current)
            case "C":
                guard
                    let x1 = nextNumber(&i), let y1 = nextNumber(&i),
                    let x2 = nextNumber(&i), let y2 = nextNumber(&i),
                    let x = nextNumber(&i), let y = nextNumber(&i)
                else { return nil }
                let c1 = CGPoint(x: x1, y: y1)
                let c2 = CGPoint(x: x2, y: y2)
                let end = CGPoint(x: x, y: y)
                p.addCurve(to: end, control1: c1, control2: c2)
                current = end
            case "Z":
                p.closeSubpath()
                current = start
            default:
                return nil
            }
        }

        return p
    }
}
