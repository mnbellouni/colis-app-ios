import SwiftUI

struct RegisterView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss)      private var dismiss

    @State private var vm: RegisterViewModel?
    @State private var email     = ""
    @State private var password  = ""
    @State private var nom       = ""
    @State private var prenom    = ""
    @State private var telephone = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Header ────────────────────────────────
                VStack(spacing: 8) {
                    Text("Créer un compte")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Text("Rejoignez la communauté ColisCo")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.top, 32)

                // ── Formulaire ────────────────────────────
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        AppTextField(title: "Prénom", placeholder: "Jean", text: $prenom)
                        AppTextField(title: "Nom",    placeholder: "Dupont", text: $nom)
                    }
                    AppTextField(
                        title:        "Email",
                        placeholder:  "votre@email.com",
                        text:         $email,
                        keyboardType: .emailAddress
                    )
                    AppTextField(
                        title:        "Téléphone",
                        placeholder:  "+33612345678",
                        text:         $telephone,
                        keyboardType: .phonePad
                    )
                    AppTextField(
                        title:       "Mot de passe",
                        placeholder: "8 caractères minimum",
                        text:        $password,
                        isSecure:    true
                    )
                }

                // ── Erreur ────────────────────────────────
                if let error = vm?.error {
                    ErrorBanner(message: error)
                }

                // ── Bouton ────────────────────────────────
                AppButton(
                    title:     "Créer mon compte",
                    action: {
                        Task {
                            await vm?.register(
                                email:     email,
                                password:  password,
                                nom:       nom,
                                prenom:    prenom,
                                telephone: telephone,
                                authState: authState
                            )
                        }
                    },
                    isLoading: vm?.isLoading ?? false
                )

                Button("Déjà un compte ? Se connecter") {
                    dismiss()
                }
                .font(.system(size: 14))
                .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vm = factory.makeRegisterViewModel()
        }
        .onChange(of: vm?.isSuccess ?? false) { _, success in
            if success { dismiss() }
        }
    }
}
