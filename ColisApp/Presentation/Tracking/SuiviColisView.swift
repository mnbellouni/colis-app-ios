import SwiftUI

struct SuiviColisView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @State private var codeInput  = ""
    @State private var tracking: ColisTracking?
    @State private var isLoading  = false
    @State private var error: String?
    @State private var hasSearched = false
    @State private var showAuth   = false
    @State private var showCreate = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Hero card "Créer un code" ─────────────
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Créer un code")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Envoi sécurisé avec code\nde transport unique")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(2)
                    }
                    Spacer()
                    Button {
                        if authState.isLoggedIn {
                            showCreate = true
                        } else {
                            showAuth = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Créer")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(99)
                    }
                }
                .padding(20)
                .background(LinearGradient.appPrimary)
                .cornerRadius(18)

                // ── Suivre un colis ───────────────────────
                VStack(alignment: .leading, spacing: 14) {
                    Text("Suivre un colis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appTextPrimary)

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 18))
                                .foregroundColor(.appTextTertiary)

                            TextField("XXXXX-XXXXX", text: $codeInput)
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .kerning(2)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .onChange(of: codeInput) { v in codeInput = formatInput(v) }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(Color.appCanvas)
                        .cornerRadius(13)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(codeInput.isEmpty ? Color.appBorder : Color.appPrimary, lineWidth: 1.5)
                        )

                        Text("10 caractères — sans O 0 I 1 L S 5 B Z U")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextTertiary)

                        AppButton(
                            title:     "Rechercher",
                            action:    { Task { await search() } },
                            isLoading: isLoading
                        )
                    }
                }
                .padding(18)
                .background(Color.appCard)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 2)

                // ── Erreur ────────────────────────────────
                if let error {
                    ErrorBanner(message: error)
                }

                // ── Résultat ──────────────────────────────
                if let tracking {
                    TrackingResultCard(tracking: tracking)
                } else if hasSearched && !isLoading && error == nil {
                    EmptyStateView(
                        icon:    "magnifyingglass",
                        title:   "Aucun résultat",
                        message: "Vérifiez le code et réessayez"
                    )
                }

                // ── Mes envois récents (si connecté) ──────
                if authState.isLoggedIn {
                    RecentShipmentsSection()
                }
            }
            .padding(18)
        }
        .background(Color.appBackground)
        .navigationTitle("Envoyer avec suivi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if authState.isLoggedIn { showCreate = true } else { showAuth = true }
                } label: {
                    Text("Créer un code")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .sheet(isPresented: $showAuth)   { AuthNavigationView() }
        .sheet(isPresented: $showCreate) { CreateAnnonceView() }
    }

    private func formatInput(_ input: String) -> String {
        let clean = String(
            input.replacingOccurrences(of: "-", with: "")
                 .replacingOccurrences(of: " ", with: "")
                 .uppercased()
                 .prefix(10)
        )
        if clean.count > 5 {
            let i = clean.index(clean.startIndex, offsetBy: 5)
            return "\(clean[..<i])-\(clean[i...])"
        }
        return clean
    }

    private func search() async {
        let clean = ColisCodeGenerator.normalize(codeInput)
        guard ColisCodeGenerator.isValid(clean) else {
            error = "Code invalide — vérifiez les 10 caractères"
            return
        }
        isLoading = true; error = nil; tracking = nil; hasSearched = true
        do {
            tracking = try await factory.makeTrackingRepository().getTracking(code: clean)
        } catch {
            self.error = "Colis introuvable — vérifiez le code"
        }
        isLoading = false
    }
}

// ── Section envois récents ────────────────────────────────
struct RecentShipmentsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mes envois récents")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                Spacer()
                NavigationLink {
                    MesLivraisonsView()
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }

            NavigationLink {
                MesLivraisonsView()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.appPrimaryLight)
                            .frame(width: 44, height: 44)
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.appPrimary)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Suivre mes livraisons")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                        Text("Codes colis, statuts et étapes")
                            .font(.system(size: 13))
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }
                .padding(16)
                .background(Color.appCard)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
}

// ── Carte résultat tracking ───────────────────────────────
struct TrackingResultCard: View {
    let tracking: ColisTracking

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text(tracking.codeFormate)
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundColor(.appPrimary)
                    .kerning(2)
                Spacer()
                StatutBadge(statut: tracking.statut)
            }

            Divider()

            Text(tracking.titre)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appTextPrimary)

            // Route visuelle
            RouteLineView(
                depart:  "\(tracking.paysDepart.flagEmoji) \(tracking.villeDepart)",
                arrivee: "\(tracking.paysArrivee.flagEmoji) \(tracking.villeArrivee)",
                moyen:   "avion"
            )

            HStack(spacing: 16) {
                Label("\(String(format: "%.1f", tracking.poids)) kg", systemImage: "scalemass")
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
                Label(tracking.categorie.capitalized, systemImage: "tag")
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
            }

            if !tracking.etapes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Historique")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    ForEach(tracking.etapes.indices, id: \.self) { i in
                        HStack(spacing: 8) {
                            Circle().fill(Color.appPrimary).frame(width: 6, height: 6)
                            Text(tracking.etapes[i].statut.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            Text(String(tracking.etapes[i].date.prefix(10)))
                                .font(.system(size: 12))
                                .foregroundColor(.appTextTertiary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.appCard)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 2)
    }
}
