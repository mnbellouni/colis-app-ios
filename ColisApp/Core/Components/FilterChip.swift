import SwiftUI

struct FilterChip: View {
    let label:      String
    let isSelected: Bool
    var glass:      Bool = false
    let action:     () -> Void

    private var radius: CGFloat { glass ? 10 : AppRadius.pill }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background { chipBackground }
                .overlay {
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(borderColor, lineWidth: isSelected && glass ? 1.5 : 1)
                }
        }
    }

    @ViewBuilder
    private var chipBackground: some View {
        if glass {
            ZStack {
                RoundedRectangle(cornerRadius: radius).fill(.ultraThinMaterial)
                if isSelected {
                    RoundedRectangle(cornerRadius: radius).fill(Color.appPrimary.opacity(0.15))
                }
            }
        } else {
            RoundedRectangle(cornerRadius: radius)
                .fill(isSelected ? Color.appPrimary : Color.appCanvas)
        }
    }

    private var textColor: Color {
        glass ? (isSelected ? .appPrimary : .appTextSecondary)
              : (isSelected ? .white      : .appTextSecondary)
    }

    private var borderColor: Color {
        glass ? (isSelected ? .appPrimary : .white.opacity(0.3))
              : (isSelected ? .clear      : .appBorder)
    }
}
