import SwiftUI

struct AuthNavigationView: View {

    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss)      private var dismiss

    var body: some View {
        NavigationStack {
            LoginView()
        }
        .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                dismiss() // ✅ Ferme la sheet après connexion
            }
        }
    }
}
