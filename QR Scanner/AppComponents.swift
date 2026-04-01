import SwiftUI

struct BrandButton: View {
    let title: String
    var filled: Bool = true
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(filled ? .white : AppTheme.Colors.ink)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.Metrics.buttonHeight)
                .background(buttonBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(filled ? Color.clear : AppTheme.Colors.line, lineWidth: 1.2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
    
    private var buttonBackground: some View {
        Group {
            if filled {
                LinearGradient(colors: [AppTheme.Colors.brand, AppTheme.Colors.brandDark], startPoint: .leading, endPoint: .trailing)
            } else {
                AppTheme.Colors.card
            }
        }
    }
}

struct ScreenHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow.uppercased())
                .font(.system(size: 12, weight: .black))
                .tracking(1.2)
                .foregroundColor(AppTheme.Colors.brand)
            Text(title)
                .font(.system(size: 34, weight: .black))
                .foregroundColor(AppTheme.Colors.ink)
                .lineSpacing(2)
            Text(subtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryInk)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeroQRCard: View {
    let accent: Color
    let label: String
    let title: String
    let subtitle: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.24), AppTheme.Colors.card],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .fill(accent.opacity(0.10))
                .frame(width: 220, height: 220)
                .offset(x: 92, y: -78)
            VStack(alignment: .leading, spacing: 16) {
                TinyPill(title: label, tint: accent, style: .soft)
                HStack(alignment: .center, spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 172, height: 172)
                            .modifier(AppShadow())
                        QRMatrixView(accent: accent)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(AppTheme.Colors.ink)
                        Text(subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(24)
        }
        .frame(height: 260)
        .appCardStyle(radius: 34)
    }
}

struct QRMatrixView: View {
    let accent: Color
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<7) { row in
                HStack(spacing: 5) {
                    ForEach(0..<7) { column in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(colorFor(row: row, column: column))
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
    }
    
    private func colorFor(row: Int, column: Int) -> Color {
        if (row < 2 && column < 2) || (row > 4 && column < 2) || (row < 2 && column > 4) {
            return AppTheme.Colors.ink
        }
        return (row + column).isMultiple(of: 2) ? AppTheme.Colors.ink : accent
    }
}

struct MetricCard: View {
    let metric: DashboardMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(metric.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.secondaryInk)
            Text(metric.value)
                .font(.system(size: 30, weight: .black))
                .foregroundColor(AppTheme.Colors.ink)
            Text(metric.subtitle)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.Colors.brand)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 128)
        .appCardStyle(radius: 26)
    }
}

enum PillStyle {
    case soft
    case solid
}

struct TinyPill: View {
    let title: String
    let tint: Color
    var style: PillStyle = .solid
    
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .black))
            .foregroundColor(style == .solid ? tint : tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background((style == .solid ? tint.opacity(0.14) : tint.opacity(0.12)))
            .clipShape(Capsule())
    }
}

struct SectionTitle: View {
    let title: String
    let subtitle: String?
    let trailing: AnyView?
    
    init(title: String, subtitle: String? = nil, trailing: AnyView? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(AppTheme.Colors.ink)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.secondaryInk)
                }
            }
            Spacer()
            trailing
        }
    }
}

struct DetailCard: View {
    let title: String
    let subtitle: String
    let footer: String
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TinyPill(title: footer, tint: accent)
            Text(title)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(AppTheme.Colors.ink)
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryInk)
                .lineSpacing(2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppTheme.Colors.line, lineWidth: 1)
        )
        .modifier(AppShadow())
    }
}

struct ActionTile: View {
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 24) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(0.16))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().fill(tint).frame(width: 14, height: 14))
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 19, weight: .black))
                        .foregroundColor(AppTheme.Colors.ink)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.Colors.secondaryInk)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 158)
            .appCardStyle(radius: 28)
        }
    }
}

struct ListRowCard: View {
    let title: String
    let subtitle: String
    let tag: String
    let tagColor: Color
    let secondaryTag: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(AppTheme.Colors.ink)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.secondaryInk)
                        .lineSpacing(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    TinyPill(title: tag, tint: tagColor)
                    if let secondaryTag = secondaryTag {
                        Text(secondaryTag)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.tertiaryInk)
                    }
                }
            }
        }
        .padding(18)
        .appCardStyle(radius: 26)
    }
}

struct InputCard: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .black))
                .foregroundColor(AppTheme.Colors.ink)
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.ink)
                .padding(.horizontal, 18)
                .frame(height: AppTheme.Metrics.inputHeight)
                .background(AppTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.Colors.line, lineWidth: 1)
                )
        }
    }
}
