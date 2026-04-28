import SwiftUI

struct ContentView: View {

    @Environment(\.factory) private var factory
    @Environment(AuthState.self) private var authState

    var body: some View {
        Group {
            if authState.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .preferredColorScheme(.light)
    }
}
