import SwiftUI

struct TagBadge: View {
    let tag: String

    var body: some View {
        Text(tag.replacingOccurrences(of: "_", with: " "))
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(20)
    }

    private var color: Color {
        if tag.contains("urgent") || tag.contains("hospitalisation") {
            return .appError
        } else if tag.contains("medicament") || tag.contains("humanitaire") {
            return .appSuccess
        } else {
            return .appPrimary
        }
    }

    private var backgroundColor: Color {
        if tag.contains("urgent") || tag.contains("hospitalisation") {
            return .appErrorLight
        } else if tag.contains("medicament") || tag.contains("humanitaire") {
            return .appSuccessLight
        } else {
            return .appPrimaryLight
        }
    }
}
