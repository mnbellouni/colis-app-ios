import SwiftUI

struct AppTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String? = nil
    var onBlur: (() -> Void)? = nil

    @State private var isVisible: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)

            HStack(spacing: 0) {
                Group {
                    if isSecure && !isVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(.system(size: 15))
                .foregroundColor(.appTextPrimary)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if !focused { onBlur?() }
                }
                .autocorrectionDisabled(isSecure)
                .textInputAutocapitalization(isSecure ? .never : .sentences)

                if isSecure {
                    Button(action: { isVisible.toggle() }) {
                        Image(systemName: isVisible ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextTertiary)
                    }
                    .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.appCanvas)
            .cornerRadius(AppRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.input)
                    .stroke(borderColor, lineWidth: 1.5)
            )

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.appError)
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return .appError }
        if isFocused { return .appPrimary }
        return .appBorder
    }
}
