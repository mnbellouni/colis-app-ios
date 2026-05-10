import SwiftUI

// Tag libre (catégories, étiquettes annonces). Pour les statuts colorés, utiliser StatutBadge.
struct TagBadge: View {
    let tag: String
    var style: Style = .default

    enum Style {
        case `default`, urgent, success
    }

    var body: some View {
        Text(tag.replacingOccurrences(of: "_", with: " "))
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(background)
            .cornerRadius(AppRadius.pill)
    }

    private var foreground: Color {
        switch style {
        case .default: return .appPrimary
        case .urgent:  return .appError
        case .success: return .appSuccess
        }
    }

    private var background: Color {
        switch style {
        case .default: return .appPrimaryLight
        case .urgent:  return .appErrorLight
        case .success: return .appSuccessLight
        }
    }
}
