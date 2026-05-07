import SwiftUI

struct SuiviTabView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @State private var codeInput   = ""
    @State private var tracking: ColisTracking?
    @State private var isLoading   = false
    @State private var error: String?
    @State private var hasSearched = false
    @State private var livraisons: [Livraison] = []
    @State private var livraisonsLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Recherche par code (toujours visible) ─
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suivre un colis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextTertiary)

                        TextField("Ex : ACDEF-34789", text: $codeInput)
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .kerning(1.5)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .onChange(of: codeInput) { v in codeInput = formatCode(v) }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color.appCanvas)
                    .cornerRadius(13)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(codeInput.isEmpty ? Color.appBorder : Color.appPrimary, lineWidth: 1.5)
                    )

                    AppButton(
                        title:     "Rechercher",
                        action:    { Task { await search() } },
                        isLoading: isLoading
                    )
                }
                .padding(18)
                .background(Color.appCard)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

                // ── Erreur ────────────────────────────────
                if let error {
                    ErrorBanner(message: error)
                }

                // ── Résultat recherche ────────────────────
                if let tracking {
                    SuiviDetailCard(tracking: tracking)
                } else if hasSearched && !isLoading && error == nil {
                    EmptyStateView(
                        icon:    "magnifyingglass",
                        title:   "Aucun résultat",
                        message: "Vérifiez le code et réessayez"
                    )
                }

                // ── Mes colis (connecté — rôle expéditeur) ─
                if authState.isLoggedIn {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mes colis envoyés")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appTextPrimary)

                        if livraisonsLoading {
                            ProgressView().tint(.appPrimary).frame(maxWidth: .infinity)
                        } else if livraisons.isEmpty {
                            EmptyStateView(
                                icon:    "shippingbox",
                                title:   "Aucun colis",
                                message: "Vos colis envoyés apparaîtront ici"
                            )
                        } else {
                            ForEach(livraisons) { livraison in
                                SuiviLivraisonCard(livraison: livraison)
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(Color.appBackground)
        .navigationTitle("Suivi")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if authState.isLoggedIn {
                await loadMesLivraisons()
            }
        }
    }

    private func formatCode(_ input: String) -> String {
        let clean = String(
            input.replacingOccurrences(of: "-", with: "")
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
        let clean = codeInput.replacingOccurrences(of: "-", with: "")
        guard clean.count == 10 else {
            error = "Code invalide — 10 caractères requis"
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

    private func loadMesLivraisons() async {
        livraisonsLoading = true
        do {
            livraisons = try await factory.makeLivraisonRepository().getMesLivraisons(role: "expediteur")
        } catch {
            // Silencieux — la liste reste vide
        }
        livraisonsLoading = false
    }
}

// ── Carte résultat de recherche par code ──────────────────
struct SuiviDetailCard: View {
    let tracking: ColisTracking

    private let etapesOrdre = ["en_attente", "recupere", "en_transit", "livre", "confirme"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tracking.titre)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Text(tracking.codeFormate)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
                StatutBadge(statut: tracking.statut)
            }

            // Progression
            ProgressionView(statut: tracking.statut)

            Divider()

            // Étapes
            VStack(alignment: .leading, spacing: 10) {
                ForEach(etapesOrdre, id: \.self) { etape in
                    let completee = tracking.etapes.first(where: { $0.statut == etape })
                    HStack(spacing: 10) {
                        Image(systemName: completee != nil ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                            .foregroundColor(completee != nil ? .appSuccess : .appTextTertiary)
                        Text(etape.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 14, weight: completee != nil ? .semibold : .regular))
                            .foregroundColor(completee != nil ? .appTextPrimary : .appTextTertiary)
                        Spacer()
                        if let date = completee?.date {
                            Text(formatDate(date))
                                .font(.system(size: 12))
                                .foregroundColor(.appTextTertiary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.appCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return String(iso.prefix(10)) }
        let display = DateFormatter()
        display.dateFormat = "d MMM · HH'h'mm"
        display.locale = Locale(identifier: "fr_FR")
        return display.string(from: date)
    }
}

// ── Carte livraison (liste mes colis) ─────────────────────
struct SuiviLivraisonCard: View {
    let livraison: Livraison

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appPrimaryLight)
                    .frame(width: 44, height: 44)
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(livraison.statut.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                ProgressionView(statut: livraison.statut)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.appTextTertiary)
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 1)
    }
}

// ── Indicateur de progression ─────────────────────────────
struct ProgressionView: View {
    let statut: String

    private let etapes = ["en_attente", "recupere", "en_transit", "livre", "confirme"]

    private var completees: Int {
        (etapes.firstIndex(of: statut) ?? 0) + 1
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<etapes.count, id: \.self) { i in
                Circle()
                    .fill(i < completees ? Color.appPrimary : Color.appBorder)
                    .frame(width: 8, height: 8)
            }
        }
    }
}
