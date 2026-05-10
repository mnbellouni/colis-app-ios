import SwiftUI

struct AuthNavigationView: View {

    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)      private var dismiss

    var onAuthenticated: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            LoginView()
        }
        .onChange(of: authState.isLoggedIn) {
            if authState.isLoggedIn {
                dismiss()
                onAuthenticated?()
            }
        }
    }
}
