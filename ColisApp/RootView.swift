import SwiftUI

struct RootView: View {

    @Environment(AuthState.self) private var authState

    var body: some View {
        if authState.isLoggedIn {
            MainTabView()
                .transition(.asymmetric(
                    insertion:  .move(edge: .trailing),
                    removal:    .move(edge: .leading)
                ))
        } else {
            AuthNavigationView()
                .transition(.asymmetric(
                    insertion:  .move(edge: .leading),
                    removal:    .move(edge: .trailing)
                ))
        }
    }
}
