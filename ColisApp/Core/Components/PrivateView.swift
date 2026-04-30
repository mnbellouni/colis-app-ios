import SwiftUI

struct PrivateView<Content: View>: View {

    @Environment(AuthState.self) private var authState
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if authState.isLoggedIn {
            content()
        } else {
            // ✅ Redirige vers Login — pas un message
            LoginView()
        }
    }
}
