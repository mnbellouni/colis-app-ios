import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary, secondary, destructive
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     return .appPrimary
        case .secondary:   return .white
        case .destructive: return .appErrorLight
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .white
        case .secondary:   return .appPrimary
        case .destructive: return .appError
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return .appPrimary
        default:         return .clear
        }
    }
}
