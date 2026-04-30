import SwiftUI

struct TrajetsView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    @State private var vm: TrajetViewModel?
    @State private var showCreate = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trajets disponibles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Text("Proposez votre trajet")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
                if authState.isLoggedIn {
                    Button {
                        showCreate = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)

            // ── Contenu ───────────────────────────────────
            if vm?.isLoading == true {
                Spacer()
                ProgressView().tint(.appPrimary)
                Spacer()
            } else if vm?.trajets.isEmpty == true {
                Spacer()
                EmptyStateView(
                    icon:    "airplane",
                    title:   "Aucun trajet",
                    message: "Soyez le premier à proposer un trajet !"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm?.trajets ?? []) { trajet in
                            TrajetCard(trajet: trajet)
                        }
                    }
                    .padding(16)
                }
                .refreshable {
                    await vm?.loadTrajets()
                }
            }
        }
        .background(Color.appBackground)
        .sheet(isPresented: $showCreate) {
            PrivateView {
                CreateTrajetView(vm: vm)
            }
        }
        .task {
            vm = factory.makeTrajetViewModel()
            await vm?.loadTrajets()
        }
    }
}

// ── Card Trajet ───────────────────────────────────────────
struct TrajetCard: View {
    let trajet: Trajet

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Route ─────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(trajet.paysDepart.flagEmoji)
                        Text(trajet.villeDepart)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                    }
                    Text(String(trajet.dateDepart.prefix(10)))
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: transportIcon(trajet.moyenTransport))
                        .font(.system(size: 18))
                        .foregroundColor(.appPrimary)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(.appTextTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(trajet.villeArrivee)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text(trajet.paysArrivee.flagEmoji)
                    }
                    Text(String(trajet.dateArrivee.prefix(10)))
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
            }

            Divider()

            // ── Détails ───────────────────────────────────
            HStack {
                Label(
                    "\(String(format: "%.1f", trajet.poidsRestant)) kg dispo",
                    systemImage: "scalemass"
                )
                .font(.system(size: 13))
                .foregroundColor(.appTextSecondary)

                Spacer()

                Text("\(String(format: "%.2f", trajet.prixParKg)) €/kg")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.appPrimary)
            }

            // ── Statut ────────────────────────────────────
            StatutBadge(statut: trajet.statut)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func transportIcon(_ moyen: String) -> String {
        switch moyen {
        case "avion":   return "airplane"
        case "voiture": return "car.fill"
        case "train":   return "tram.fill"
        case "bateau":  return "ferry.fill"
        default:        return "shippingbox.fill"
        }
    }
}
