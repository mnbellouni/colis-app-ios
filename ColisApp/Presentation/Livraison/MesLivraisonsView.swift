import SwiftUI

struct MesLivraisonsView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @State private var livraisons:    [Livraison] = []
    @State private var isLoading      = true
    @State private var error: String? = nil
    @State private var filtreStatut   = "toutes"

    let filtres = [
        ("Toutes",    "toutes"),
        ("En cours",  "encours"),
        ("Terminées", "terminees"),
        ("Litiges",   "litiges")
    ]

    var livraisonsFiltered: [Livraison] {
        switch filtreStatut {
        case "encours":   return livraisons.filter { ["en_attente","recupere","en_transit"].contains($0.statut) }
        case "terminees": return livraisons.filter { ["livre","confirme"].contains($0.statut) }
        case "litiges":   return livraisons.filter { $0.statut == "litige" }
        default:          return livraisons
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView().tint(.appPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error {
                EmptyStateView(icon: "wifi.slash", title: "Erreur", message: error)
            } else if livraisons.isEmpty {
                EmptyStateView(icon: "shippingbox", title: "Aucune livraison",
                               message: "Vos livraisons en tant qu'expéditeur apparaîtront ici.")
            } else {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filtres, id: \.0) { label, val in
                                FilterChip(label: label, isSelected: filtreStatut == val) {
                                    filtreStatut = val
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.vertical, 10)
                    .background(Color.appBackground)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(livraisonsFiltered) { livraison in
                                LivraisonListCard(livraison: livraison,
                                    onConfirmer: livraison.statut == "livre"
                                        ? { Task { await confirmerReception(livraison) } }
                                        : nil
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .refreshable { await load() }
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Mes livraisons")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        error     = nil
        do {
            livraisons = try await factory.makeLivraisonRepository().getMesLivraisons(role: "expediteur")
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func confirmerReception(_ livraison: Livraison) async {
        do {
            let updated = try await factory.makeLivraisonRepository().updateStatut(id: livraison.id, statut: "confirme")
            if let i = livraisons.firstIndex(where: { $0.id == livraison.id }) {
                livraisons[i] = updated
            }
        } catch {}
    }
}

// ── Carte livraison liste ─────────────────────────────────

struct LivraisonListCard: View {
    let livraison:   Livraison
    let onConfirmer: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Livraison · \(String(livraison.annonceId.prefix(8)))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    StatutLivraisonBadge(statut: livraison.statut)
                }
                Spacer()
                Text(String(livraison.createdAt.prefix(10)))
                    .font(.system(size: 12))
                    .foregroundColor(.appTextTertiary)
            }

            ProgressionView(statut: livraison.statut)

            if let onConfirmer {
                AppButton(title: "Confirmer la réception", action: onConfirmer)
            }

            if livraison.statut == "litige" {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.appError)
                    Text("Litige en cours — contactez le transporteur")
                        .font(.system(size: 13))
                        .foregroundColor(.appError)
                }
                .padding(10)
                .background(Color.appErrorLight)
                .cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

struct StatutLivraisonBadge: View {
    let statut: String

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(20)
    }

    private var label: String {
        switch statut {
        case "en_attente": return "En attente"
        case "recupere":   return "Récupéré"
        case "en_transit": return "En transit"
        case "livre":      return "Livré"
        case "confirme":   return "Confirmé"
        case "litige":     return "Litige"
        default:           return statut.capitalized
        }
    }

    private var color: Color {
        switch statut {
        case "confirme":   return .appSuccess
        case "livre":      return .appSuccess
        case "en_transit": return .appPrimary
        case "recupere":   return .appInfo
        case "litige":     return .appError
        default:           return .appTextSecondary
        }
    }
}

// ── Vue détail livraison unique (ancienne vue) ────────────

struct LivraisonDetailView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    let livraisonId: String

    @StateObject private var vmHolder = VMHolder<LivraisonViewModel>()
    private var vm: LivraisonViewModel? { vmHolder.vm }

    var body: some View {
        Group {
            if vm?.isLoading == true {
                ProgressView().tint(.appPrimary)
            } else if let livraison = vm?.livraison {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let tracking = vm?.tracking {
                            NavigationLink { ColisCodeView(tracking: tracking) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "number.square").font(.system(size: 22)).foregroundColor(.appPrimary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Code colis").font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
                                        Text(tracking.codeFormate)
                                            .font(.system(size: 20, weight: .heavy, design: .monospaced))
                                            .foregroundColor(.appPrimary).kerning(2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.appTextTertiary)
                                }
                                .padding(16).background(Color.appPrimaryLight).cornerRadius(16)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Statut").font(.system(size: 13, weight: .semibold)).foregroundColor(.appTextSecondary)
                            StatutBadge(statut: livraison.statut)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suivi").font(.system(size: 13, weight: .semibold)).foregroundColor(.appTextSecondary)
                            ForEach(livraison.etapes.indices, id: \.self) { i in
                                EtapeRow(etape: livraison.etapes[i], isLast: i == livraison.etapes.count - 1, isDone: true)
                            }
                        }
                        .padding(16).background(Color.appCard).cornerRadius(16)

                        if livraison.voyageurId == authState.userId {
                            VStack(spacing: 12) {
                                if livraison.statut == "en_attente" {
                                    AppButton(title: "Colis récupéré") {
                                        Task { await vm?.updateStatut(livraisonId: livraison.id, statut: "recupere") }
                                    }
                                }
                                if livraison.statut == "recupere" {
                                    AppButton(title: "En transit") {
                                        Task { await vm?.updateStatut(livraisonId: livraison.id, statut: "en_transit") }
                                    }
                                }
                                if livraison.statut == "en_transit" {
                                    AppButton(title: "Livré") {
                                        Task { await vm?.updateStatut(livraisonId: livraison.id, statut: "livre") }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            } else {
                EmptyStateView(icon: "shippingbox", title: "Livraison introuvable", message: "")
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Détail livraison")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vmHolder.vm = factory.makeLivraisonViewModel()
            await vm?.load(livraisonId: livraisonId)
        }
    }
}

struct EtapeRow: View {
    let etape:  Etape
    let isLast: Bool
    let isDone: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle().fill(isDone ? Color.appPrimary : Color.appBorder).frame(width: 12, height: 12).padding(.top, 3)
                if !isLast { Rectangle().fill(isDone ? Color.appPrimary.opacity(0.3) : Color.appBorder).frame(width: 2, height: 40) }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(etape.statut.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.appTextPrimary)
                Text(String(etape.date.prefix(16)).replacingOccurrences(of: "T", with: " à "))
                    .font(.system(size: 12)).foregroundColor(.appTextSecondary)
            }
            Spacer()
        }
    }
}
