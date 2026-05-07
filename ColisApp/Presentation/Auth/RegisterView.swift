import SwiftUI
import Combine

struct RegisterView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)        private var dismiss

    @StateObject private var vmHolder = VMHolder<RegisterViewModel>()
    private var vm: RegisterViewModel? { vmHolder.vm }

    @State private var email          = ""
    @State private var password       = ""
    @State private var confirmPassword = ""
    @State private var nom            = ""
    @State private var prenom         = ""
    @State private var telephone      = ""
    @State private var showPassword   = false
    @State private var showConfirm    = false

    // Validation
    @State private var emailError:    String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmError:  String? = nil

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
                        AppTextField(title: "Prénom", placeholder: "Votre prénom", text: $prenom)
                        AppTextField(title: "Nom",    placeholder: "Votre nom de famille", text: $nom)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        AppTextField(
                            title:        "Email",
                            placeholder:  "Votre adresse email",
                            text:         $email,
                            keyboardType: .emailAddress
                        )
                        .onSubmit { validateEmail() }
                        if let err = emailError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                    }

                    AppTextField(
                        title:        "Téléphone",
                        placeholder:  "Ex : +33 6 00 00 00 00",
                        text:         $telephone,
                        keyboardType: .phonePad
                    )

                    // Mot de passe
                    VStack(alignment: .leading, spacing: 4) {
                        PasswordField(
                            title:       "Mot de passe",
                            placeholder: "Créez un mot de passe",
                            text:        $password,
                            show:        $showPassword
                        )
                        .onSubmit { validatePassword() }
                        if let err = passwordError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                        PasswordStrengthBar(password: password)
                    }

                    // Confirmation
                    VStack(alignment: .leading, spacing: 4) {
                        PasswordField(
                            title:       "Confirmation mot de passe",
                            placeholder: "Confirmez votre mot de passe",
                            text:        $confirmPassword,
                            show:        $showConfirm
                        )
                        .onSubmit { validateConfirm() }
                        if let err = confirmError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                    }
                }

                // ── Erreur backend ────────────────────────
                if let error = vm?.error {
                    ErrorBanner(message: error)
                }

                // ── Bouton ────────────────────────────────
                AppButton(
                    title:     "Créer mon compte",
                    action: {
                        validateEmail()
                        validatePassword()
                        validateConfirm()
                        guard emailError == nil, passwordError == nil, confirmError == nil else { return }
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

                Button("Déjà un compte ? Se connecter") { dismiss() }
                    .font(.system(size: 14))
                    .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .task { vmHolder.vm = factory.makeRegisterViewModel() }
        .onChange(of: vm?.isSuccess ?? false) { success in
            if success { dismiss() }
        }
        .onChange(of: password) { _ in
            if confirmPassword.isEmpty == false { validateConfirm() }
        }
    }

    private func validateEmail() {
        if email.isEmpty {
            emailError = "L'email est obligatoire"
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Format email invalide"
        } else if email.contains(" ") {
            emailError = "Format email invalide"
        } else {
            emailError = nil
        }
    }

    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Le mot de passe est obligatoire"
        } else if password.count < 8 {
            passwordError = "8 caractères minimum"
        } else if !password.contains(where: { $0.isUppercase }) {
            passwordError = "Au moins une lettre majuscule"
        } else if !password.contains(where: { $0.isNumber }) {
            passwordError = "Au moins un chiffre"
        } else if !password.contains(where: { "!@#$%^&*".contains($0) }) {
            passwordError = "Au moins un caractère spécial (!@#$%^&*)"
        } else {
            passwordError = nil
        }
    }

    private func validateConfirm() {
        if confirmPassword.isEmpty {
            confirmError = "La confirmation est obligatoire"
        } else if confirmPassword != password {
            confirmError = "Les mots de passe ne correspondent pas"
        } else {
            confirmError = nil
        }
    }
}

// ── Champ mot de passe avec toggle visibilité ─────────────
struct PasswordField: View {
    let title:       String
    let placeholder: String
    @Binding var text: String
    @Binding var show: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)
            HStack {
                Group {
                    if show {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.system(size: 15))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button { show.toggle() } label: {
                    Image(systemName: show ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundColor(.appTextTertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.appBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appBorder, lineWidth: 1))
        }
    }
}

// ── Barre de force du mot de passe ────────────────────────
struct PasswordStrengthBar: View {
    let password: String

    private var score: Int {
        var s = 0
        if password.count >= 8 { s += 1 }
        if password.contains(where: { $0.isUppercase }) { s += 1 }
        if password.contains(where: { $0.isNumber }) { s += 1 }
        if password.contains(where: { "!@#$%^&*".contains($0) }) { s += 1 }
        return s
    }

    private var color: Color {
        score <= 2 ? .appError : score == 3 ? .appWarning : .appSuccess
    }

    private var label: String {
        score <= 2 ? "Faible" : score == 3 ? "Moyen" : "Fort"
    }

    var body: some View {
        if !password.isEmpty {
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < score ? color : Color.appBorder)
                        .frame(height: 4)
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
            }
        }
    }
}
