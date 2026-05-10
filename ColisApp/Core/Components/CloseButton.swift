import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1))
        }
    }
}
