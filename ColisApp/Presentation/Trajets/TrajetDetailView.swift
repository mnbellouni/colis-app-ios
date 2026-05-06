import SwiftUI

struct TrajetDetailView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    let trajetId: String

    @StateObject private var vmHolder = VMHolder<TrajetViewModel>()
    private var vm: TrajetViewModel? { vmHolder.vm }
    @State private var showLogin = false

    private var trajet: Trajet? { vm?.selectedTrajet }

    var body: some View {
        ScrollView {
            if let trajet {
                VStack(alignment: .leading, spacing: 20) {

                    routeSection(trajet)

                    HStack(spacing: 12) {
                        DetailItem(
                            icon:  transportIcon(trajet.moyenTransport),
                            label: "Transport",
                            value: trajet.moyenTransport.capitalized
                        )
                        DetailItem(
                            icon:  "scalemass",
                            label: "Poids dispo",
                            value: "\(String(format: "%.1f", trajet.poidsRestant)) kg"
                        )
                        DetailItem(
                            icon:  "eurosign.circle",
                            label: "Prix/kg",
                            value: "\(String(format: "%.2f", trajet.prixParKg)) €"
                        )
                    }

                    if !trajet.categoriesAcceptees.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Catégories acceptées")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                            FlowLayout(spacing: 6) {
                                ForEach(trajet.categoriesAcceptees, id: \.self) { cat in
                                    TagBadge(tag: cat)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.appCard)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Estimation de coût")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appTextSecondary)

                        HStack(spacing: 0) {
                            estimationCard(poids: 1, prixKg: trajet.prixParKg)
                            Divider().frame(height: 50)
                            estimationCard(poids: 5, prixKg: trajet.prixParKg)
                            Divider().frame(height: 50)
                            estimationCard(poids: 10, prixKg: trajet.prixParKg)
                        }
                        .padding(.vertical, 12)
                        .background(Color.appCard)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dates")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appTextSecondary)

                        HStack(spacing: 16) {
                            dateCard(
                                label: "Départ",
                                date:  String(trajet.dateDepart.prefix(10)),
                                icon:  "airplane.departure"
                            )
                            dateCard(
                                label: "Arrivée",
                                date:  String(trajet.dateArrivee.prefix(10)),
                                icon:  "airplane.arrival"
                            )
                        }
                    }

                    HStack {
                        Text("Statut")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        StatutBadge(statut: trajet.statut)
                    }

                    if trajet.voyageurId != authState.userId && trajet.isOuvert {
                        if authState.isLoggedIn {
                            NavigationLink {
                                ChatView(
                                    conversationId: [authState.userId ?? "", trajet.voyageurId].sorted().joined(separator: "_"),
                                    autreUserId: trajet.voyageurId
                                )
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 14))
                                    Text("Contacter le voyageur")
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .frame(height: 52)
                                .background(LinearGradient.appPrimary)
                                .cornerRadius(13)
                            }
                        } else {
                            AppButton(
                                title:  "Connectez-vous pour contacter",
                                action: { showLogin = true },
                                style:  .secondary
                            )
                        }
                    }
                }
                .padding(18)
            } else if vm?.isLoading == true {
                ProgressView()
                    .tint(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let error = vm?.error {
                EmptyStateView(
                    icon:    "exclamationmark.triangle",
                    title:   "Erreur",
                    message: error
                )
                .padding(.top, 60)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Détail du trajet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .sheet(isPresented: $showLogin) {
            AuthNavigationView()
        }
        .task {
            vmHolder.vm = factory.makeTrajetViewModel()
            await vm?.loadTrajet(id: trajetId)
        }
    }

    private func routeSection(_ trajet: Trajet) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Itinéraire")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .padding(.bottom, 12)

            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 12, height: 12)

                    if let etapes = trajet.etapes, !etapes.isEmpty {
                        ForEach(etapes) { _ in
                            Rectangle()
                                .fill(Color.appPrimary.opacity(0.3))
                                .frame(width: 2, height: 40)
                            Circle()
                                .fill(Color.appPrimary.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Rectangle()
                        .fill(Color.appPrimary.opacity(0.3))
                        .frame(width: 2, height: 40)
                    Circle()
                        .fill(Color.appSuccess)
                        .frame(width: 12, height: 12)
                }

                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(trajet.paysDepart.flagEmoji) \(trajet.villeDepart)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text("Départ — \(String(trajet.dateDepart.prefix(10)))")
                            .font(.system(size: 12))
                            .foregroundColor(.appTextSecondary)
                    }

                    if let etapes = trajet.etapes, !etapes.isEmpty {
                        ForEach(etapes) { etape in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(etape.pays.flagEmoji) \(etape.ville)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appTextPrimary)
                                Text("Escale")
                                    .font(.system(size: 11))
                                    .foregroundColor(.appTextTertiary)
                            }
                            .padding(.top, 20)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(trajet.paysArrivee.flagEmoji) \(trajet.villeArrivee)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        Text("Arrivée — \(String(trajet.dateArrivee.prefix(10)))")
                            .font(.system(size: 12))
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func estimationCard(poids: Double, prixKg: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(poids)) kg")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)
            Text("\(String(format: "%.2f", poids * prixKg)) €")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private func dateCard(label: String, date: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.appPrimary)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
                Text(date)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
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
