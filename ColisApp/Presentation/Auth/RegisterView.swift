import SwiftUI
import Combine

struct RegisterView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)        private var dismiss

    @StateObject private var vmHolder = VMHolder<RegisterViewModel>()
    private var vm: RegisterViewModel? { vmHolder.vm }

    @State private var email     = ""
    @State private var password  = ""
    @State private var nom       = ""
    @State private var prenom    = ""
    @State private var telephone = ""
    @State private var showCertification = false

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
            vmHolder.vm = factory.makeRegisterViewModel()
        }
        .onChange(of: vm?.isSuccess ?? false) { success in
            if success { showCertification = true }
        }
        .sheet(isPresented: $showCertification) {
            CertificationFlowView(
                accountNom: nom,
                accountPrenom: prenom,
                source: "Inscription"
            ) {
                dismiss()
            }
        }
    }
}
