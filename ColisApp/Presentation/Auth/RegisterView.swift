import SwiftUI

struct RegisterView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)        private var dismiss

    @StateObject private var vmHolder = VMHolder<RegisterViewModel>()
    private var vm: RegisterViewModel? { vmHolder.vm }

    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var nom             = ""
    @State private var prenom          = ""
    @State private var localPhoneNumber  = ""
    @State private var selectedCountry: Country = defaultCountry()

    // Validation
    @State private var emailError:    String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmError:  String? = nil
    @State private var phoneError:    String? = nil

    @State private var emailTouched    = false
    @State private var passwordTouched = false
    @State private var confirmTouched  = false
    @State private var phoneTouched    = false

    private var e164Phone: String {
        let digits = localPhoneNumber.filter(\.isNumber)
        guard !digits.isEmpty else { return "" }
        let stripped = selectedCountry.leadingZero && digits.hasPrefix("0")
            ? String(digits.dropFirst()) : digits
        return selectedCountry.dialCode + stripped
    }

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
                            keyboardType: .emailAddress,
                            onBlur:       { if emailTouched { validateEmail() } }
                        )
                        .onChange(of: email) { emailTouched = true }
                        if let err = emailError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                    }

                    CountryPhoneField(
                        localNumber:     $localPhoneNumber,
                        selectedCountry: $selectedCountry,
                        errorMessage:    phoneError,
                        onBlur:          { phoneTouched = true; validatePhone() }
                    )
                    .onChange(of: localPhoneNumber) { phoneTouched = true }

                    // Mot de passe
                    VStack(alignment: .leading, spacing: 4) {
                        AppTextField(
                            title:       "Mot de passe",
                            placeholder: "Créez un mot de passe",
                            text:        $password,
                            isSecure:    true,
                            onBlur:      { if passwordTouched { validatePassword() } }
                        )
                        .onChange(of: password) { passwordTouched = true }
                        if let err = passwordError {
                            Text(err).font(.system(size: 12)).foregroundColor(.appError)
                        }
                        PasswordStrengthBar(password: password)
                    }

                    // Confirmation
                    VStack(alignment: .leading, spacing: 4) {
                        AppTextField(
                            title:       "Confirmation mot de passe",
                            placeholder: "Confirmez votre mot de passe",
                            text:        $confirmPassword,
                            isSecure:    true,
                            onBlur:      { if confirmTouched { validateConfirm() } }
                        )
                        .onChange(of: confirmPassword) { confirmTouched = true }
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
                        validatePhone()
                        guard emailError == nil, passwordError == nil, confirmError == nil, phoneError == nil else { return }
                        Task {
                            await vm?.register(
                                email:     email,
                                password:  password,
                                nom:       nom,
                                prenom:    prenom,
                                telephone: e164Phone,
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { vmHolder.vm = factory.makeRegisterViewModel() }
        .onChange(of: vm?.isSuccess ?? false) {
            if vm?.isSuccess == true { dismiss() }
        }
        .onChange(of: password) {
            if confirmTouched { validateConfirm() }
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

    private func isValidEmailFormat(_ email: String) -> Bool {
        let parts = email.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else { return false }
        let domain = String(parts[1])
        guard let dotIndex = domain.lastIndex(of: ".") else { return false }
        let tld = domain[domain.index(after: dotIndex)...]
        return tld.count >= 2
    }

    private func validatePhone() {
        guard !localPhoneNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            phoneError = nil
            return
        }
        let e164 = e164Phone
        let regex = #"^\+[1-9]\d{6,14}$"#
        phoneError = e164.range(of: regex, options: .regularExpression) != nil
            ? nil : "Numéro invalide pour ce pays"
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
