import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary, secondary, outline, danger
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .white : .appPrimary)
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(background)
            .cornerRadius(13)
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .stroke(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
            .shadow(
                color: style == .primary ? Color(hex: "00875A").opacity(0.30) : .clear,
                radius: 10, x: 0, y: 4
            )
        }
        .disabled(isLoading)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            LinearGradient.appPrimary
        case .secondary:
            Color.appPrimaryLight
        case .outline:
            Color.clear
        case .danger:
            Color.appErrorLight
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:   return .white
        case .secondary: return .appPrimary
        case .outline:   return .appTextSecondary
        case .danger:    return .appError
        }
    }

    private var borderColor: Color {
        style == .outline ? Color.appBorder : .clear
    }
}
