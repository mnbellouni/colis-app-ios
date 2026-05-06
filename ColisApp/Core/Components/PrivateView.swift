import SwiftUI

struct PrivateView<Content: View>: View {

    @EnvironmentObject private var authState: AuthState
    @State private var showAuth = false
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if authState.isLoggedIn {
            content()
        } else {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.system(size: 52))
                    .foregroundColor(.appTextTertiary)
                Text("Connexion requise")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                Text("Connectez-vous pour accéder à cette section")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                AppButton(title: "Se connecter") { showAuth = true }
                    .padding(.horizontal, 40)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .sheet(isPresented: $showAuth) {
                AuthNavigationView()
            }
        }
    }
}
