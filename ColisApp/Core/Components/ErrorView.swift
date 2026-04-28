import SwiftUI

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.appError)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.appError)
            Spacer()
        }
        .padding(12)
        .background(Color.appErrorLight)
        .cornerRadius(10)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.appTextTertiary)
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
