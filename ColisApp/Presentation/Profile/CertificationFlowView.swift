import SwiftUI

struct CertificationFlowView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authState: AuthState

    let accountNom: String
    let accountPrenom: String
    let source: String
    var isAlreadyVerified: Bool = false

    @State private var isLoading = false
    @State private var isSubmitted = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Icône ─────────────────────────────
                    ZStack {
                        Circle()
                            .fill(isAlreadyVerified ? Color.appSuccessLight : Color.appPrimaryLight)
                            .frame(width: 80, height: 80)
                        Image(systemName: isAlreadyVerified ? "checkmark.seal.fill" : "person.badge.shield.checkmark.fill")
                            .font(.system(size: 36))
                            .foregroundColor(isAlreadyVerified ? .appSuccess : .appPrimary)
                    }
                    .padding(.top, 24)

                    // ── Titre ─────────────────────────────
                    VStack(spacing: 8) {
                        Text(isAlreadyVerified ? "Identité vérifiée" : "Vérifier mon identité")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text(isAlreadyVerified
                            ? "Votre compte est certifié. Vous pouvez faire des offres et créer des trajets."
                            : "La certification est requise pour faire une offre et créer un trajet."
                        )
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                    }

                    if !isAlreadyVerified {

                        // ── Infos compte ──────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Informations du compte")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Prénom")
                                        .font(.system(size: 11))
                                        .foregroundColor(.appTextTertiary)
                                    Text(accountPrenom.isEmpty ? "—" : accountPrenom)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.appTextPrimary)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Nom")
                                        .font(.system(size: 11))
                                        .foregroundColor(.appTextTertiary)
                                    Text(accountNom.isEmpty ? "—" : accountNom)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.appTextPrimary)
                                }
                            }
                            .padding(14)
                            .background(Color.appCanvas)
                            .cornerRadius(13)
                        }

                        // ── Ce qui est requis ─────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Documents requis")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            ForEach([
                                ("doc.text.fill", "Pièce d'identité (CNI, Passeport)"),
                                ("camera.fill",   "Photo de vous avec le document"),
                                ("checkmark.circle.fill", "Délai de traitement : 24–48h")
                            ], id: \.0) { icon, text in
                                HStack(spacing: 12) {
                                    Image(systemName: icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(.appPrimary)
                                        .frame(width: 20)
                                    Text(text)
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextPrimary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.appPrimaryLight)
                        .cornerRadius(13)

                        if let error {
                            ErrorBanner(message: error)
                        }

                        if isSubmitted {
                            HStack(spacing: 10) {
                                Image(systemName: "hourglass")
                                    .foregroundColor(.appWarning)
                                Text("Demande envoyée — nous reviendrons vers vous sous 48h.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextPrimary)
                            }
                            .padding(14)
                            .background(Color.appWarningLight)
                            .cornerRadius(13)
                        } else {
                            AppButton(
                                title:     "Soumettre ma demande",
                                action:    { Task { await submit() } },
                                isLoading: isLoading
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.appBackground)
            .navigationTitle("Certification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton { dismiss() }
                }
            }
        }
    }

    private func submit() async {
        guard let userId = authState.userId,
              let token  = KeychainStorage().get(forKey: KeychainStorage.Keys.accessToken),
              let url    = URL(string: APIEndpoints.userCertification(id: userId)) else { return }

        isLoading = true
        error = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["nom": accountNom, "prenom": accountPrenom]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200...299).contains(code) {
                isSubmitted = true
            } else {
                error = "Erreur lors de l'envoi. Réessayez."
            }
        } catch {
            self.error = "Connexion impossible. Vérifiez votre réseau."
        }

        isLoading = false
    }
}
