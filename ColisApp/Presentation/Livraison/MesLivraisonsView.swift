import SwiftUI

struct MesLivraisonsView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    @State private var vm: LivraisonViewModel?

    var body: some View {
        Group {
            if vm?.isLoading == true {
                ProgressView().tint(.appPrimary)
            } else if let livraison = vm?.livraison {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // ── Statut ────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Statut")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            StatutBadge(statut: livraison.statut)
                        }

                        // ── Étapes ────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suivi")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            ForEach(livraison.etapes.indices, id: \.self) { index in
                                EtapeRow(
                                    etape:    livraison.etapes[index],
                                    isLast:   index == livraison.etapes.count - 1,
                                    isDone:   true
                                )
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)

                        // ── Actions voyageur ──────────────
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
                EmptyStateView(
                    icon:    "shippingbox",
                    title:   "Aucune livraison",
                    message: "Vos livraisons apparaîtront ici"
                )
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Mes livraisons")
        .navigationBarTitleDisplayMode(.large)
        .task {
            vm = factory.makeLivraisonViewModel()
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
                Circle()
                    .fill(isDone ? Color.appPrimary : Color.appBorder)
                    .frame(width: 12, height: 12)
                    .padding(.top, 3)
                if !isLast {
                    Rectangle()
                        .fill(isDone ? Color.appPrimary.opacity(0.3) : Color.appBorder)
                        .frame(width: 2, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(etape.statut.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                Text(String(etape.date.prefix(16)).replacingOccurrences(of: "T", with: " à "))
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()
        }
    }
}
