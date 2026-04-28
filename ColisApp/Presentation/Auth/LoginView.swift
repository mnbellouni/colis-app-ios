import SwiftUI

struct LoginView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    @State private var vm: LoginViewModel?
    @State private var email    = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // ── Logo ──────────────────────────────
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimaryLight)
                                .frame(width: 80, height: 80)
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.appPrimary)
                        }
                        Text("ColisCo")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text("Transportez et faites transporter")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.top, 48)

                    // ── Formulaire ────────────────────────
                    VStack(spacing: 16) {
                        AppTextField(
                            title:       "Email",
                            placeholder: "votre@email.com",
                            text:        $email,
                            keyboardType: .emailAddress
                        )
                        AppTextField(
                            title:       "Mot de passe",
                            placeholder: "••••••••",
                            text:        $password,
                            isSecure:    true
                        )
                    }

                    // ── Erreur ────────────────────────────
                    if let error = vm?.error {
                        ErrorBanner(message: error)
                    }

                    // ── Bouton connexion ──────────────────
                    AppButton(
                        title:     "Se connecter",
                        action:    { Task { await vm?.login(email: email, password: password, authState: authState) } },
                        isLoading: vm?.isLoading ?? false
                    )

                    // ── Inscription ───────────────────────
                    Button {
                        showRegister = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Pas encore de compte ?")
                                .foregroundColor(.appTextSecondary)
                            Text("S'inscrire")
                                .foregroundColor(.appPrimary)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.appBackground)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
        .task {
            vm = factory.makeLoginViewModel()
        }
    }
}
