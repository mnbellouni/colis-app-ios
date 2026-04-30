import SwiftUI

struct RootView: View {

    @Environment(AuthState.self) private var authState

    var body: some View {
        if authState.isLoggedIn {
            MainTabView()
                .transition(.move(edge: .trailing))
        } else {
            NavigationStack {
                LoginView()
            }
            .transition(.move(edge: .leading))
        }
    }
}
