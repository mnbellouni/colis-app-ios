import SwiftUI

struct LoginView: View {

    @Environment(\.factory)        private var factory
    @Environment(\.dismiss)        private var dismiss
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<LoginViewModel>()
    private var vm: LoginViewModel? { vmHolder.vm }

    @State private var email        = ""
    @State private var password     = ""
    @State private var showRegister = false

    @State private var emailError:    String? = nil
    @State private var passwordError: String? = nil

    @State private var emailTouched    = false
    @State private var passwordTouched = false

    var body: some View {
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
                    VStack(alignment: .leading, spacing: 4) {
                        AppTextField(
                            title:        "Email",
                            placeholder:  "Votre adresse email",
                            text:         $email,
                            keyboardType: .emailAddress,
                            onBlur:       { if emailTouched { validateEmail() } }
                        )
                        .onChange(of: email) { emailTouched = true }
                        if let err = emailError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        AppTextField(
                            title:       "Mot de passe",
                            placeholder: "Votre mot de passe",
                            text:        $password,
                            isSecure:    true,
                            onBlur:      { if passwordTouched { validatePassword() } }
                        )
                        .onChange(of: password) { passwordTouched = true }
                        if let err = passwordError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                    }
                }

                // ── Erreur backend ────────────────────
                if let error = vm?.error {
                    ErrorBanner(message: error)
                }

                // ── Bouton connexion ──────────────────
                AppButton(
                    title:     "Se connecter",
                    action: {
                        validateEmail()
                        validatePassword()
                        guard emailError == nil, passwordError == nil else { return }
                        Task { await vm?.login(email: email, password: password, authState: authState) }
                    },
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }
        }
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
        .task {
            vmHolder.vm = factory.makeLoginViewModel()
        }
    }

    private func validateEmail() {
        if email.isEmpty {
            emailError = "L'email est obligatoire"
        } else if email.contains(" ") || !isValidEmailFormat(email) {
            emailError = "Format email invalide"
        } else {
            emailError = nil
        }
    }

    private func validatePassword() {
        passwordError = password.isEmpty ? "Le mot de passe est obligatoire" : nil
    }

    private func isValidEmailFormat(_ email: String) -> Bool {
        let parts = email.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else { return false }
        let domain = String(parts[1])
        guard let dotIndex = domain.lastIndex(of: ".") else { return false }
        let tld = domain[domain.index(after: dotIndex)...]
        return tld.count >= 2
    }
}
