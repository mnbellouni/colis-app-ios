import SwiftUI

struct ContentView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

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
