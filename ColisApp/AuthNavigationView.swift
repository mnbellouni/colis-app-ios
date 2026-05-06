import SwiftUI

struct AuthNavigationView: View {

    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)      private var dismiss

    var body: some View {
        NavigationStack {
            LoginView()
        }
        .onChange(of: authState.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                dismiss()
            }
        }
    }
}
