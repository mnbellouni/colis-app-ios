import SwiftUI

struct AnnonceDetailView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss)      private var dismiss

    let annonceId: String

    @State private var vm: AnnonceDetailViewModel?
    @State private var showOffreSheet = false
    @State private var showLogin = false

    var body: some View {
        ScrollView {
            if let annonce = vm?.annonce {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Photos ────────────────────────────
                    if !annonce.photos.isEmpty {
                        AsyncImage(url: URL(string: annonce.photos[0])) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.appBackground
                        }
                        .frame(height: 200)
                        .clipped()
                    } else {
                        ZStack {
                            Color.appPrimaryLight
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.appPrimary.opacity(0.4))
                        }
                        .frame(height: 160)
                    }

                    VStack(alignment: .leading, spacing: 20) {

                        // ── Titre + Prix ──────────────────
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(annonce.titre)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                HStack(spacing: 6) {
                                    StatutBadge(statut: annonce.statut)
                                    if annonce.isBoosted {
                                        Text("⭐ Boosté")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.appWarning)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.appWarningLight)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            Spacer()
                            Text("\(Int(annonce.budgetTransport)) €")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appPrimary)
                        }

                        // ── Route ─────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trajet")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            HStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.appPrimary)
                                        .frame(width: 10, height: 10)
                                    Rectangle()
                                        .fill(Color.appBorder)
                                        .frame(width: 1, height: 30)
                                    Circle()
                                        .fill(Color.appSuccess)
                                        .frame(width: 10, height: 10)
                                }

                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(annonce.paysDepart.flagEmoji) \(annonce.villeDepart)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.appTextPrimary)
                                        Text(annonce.adresseDepart)
                                            .font(.system(size: 13))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\((annonce.paysArrivee ?? "").flagEmoji) \(annonce.villeArrivee ?? "")")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.appTextPrimary)
                                        Text(annonce.adresseArrivee ?? "")
                                            .font(.system(size: 13))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.appBackground)
                        .cornerRadius(12)

                        // ── Détails ───────────────────────
                        HStack(spacing: 12) {
                            DetailItem(icon: "scalemass",    label: "Poids",    value: "\(String(format: "%.1f", annonce.poids)) kg")
                            DetailItem(icon: "tag",          label: "Catégorie", value: annonce.categorie.capitalized)
                            DetailItem(icon: "exclamationmark.triangle", label: "Fragile", value: annonce.fragile ? "Oui" : "Non")
                        }

                        // ── Description ───────────────────
                        if !annonce.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                Text(annonce.description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.appTextPrimary)
                            }
                        }

                        // ── Tags ──────────────────────────
                        if !annonce.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                FlowLayout(spacing: 6) {
                                    ForEach(annonce.tags, id: \.self) { tag in
                                        TagBadge(tag: tag)
                                    }
                                }
                            }
                        }

                        // ── Offres reçues ─────────────────
                        if let offres = vm?.offres, !offres.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Offres reçues (\(offres.count))")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appTextSecondary)
                                ForEach(offres) { offre in
                                    OffreRow(offre: offre)
                                }
                            }
                        }

                        // ── Bouton faire une offre ────────
                        if annonce.demandeurId != authState.userId
                            && annonce.statut == "ouverte" {
                            if authState.isLoggedIn {
                                AppButton(
                                    title:  "Faire une offre",
                                    action: { showOffreSheet = true }
                                )
                            } else {
                                AppButton(
                                    title:  "Connectez-vous pour faire une offre",
                                    action: { showLogin = true },
                                    style:  .secondary
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            } else if vm?.isLoading == true {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .background(Color.appBackground)
        .sheet(isPresented: $showOffreSheet) {
            CreateOffreView(
                annonceId: annonceId,
                vm:        vm
            )
        }
        .task {
            vm = factory.makeAnnonceDetailViewModel()
            await vm?.load(id: annonceId)
        }
    }
}

struct DetailItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.appPrimary)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }
}

struct OffreRow: View {
    let offre: Offre

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: transportIcon)
                        .font(.system(size: 12))
                        .foregroundColor(.appPrimary)
                    Text(offre.moyenTransport.capitalized)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextPrimary)
                }
                Text(offre.message)
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Text("\(Int(offre.fraisService)) €")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appPrimary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }

    private var transportIcon: String {
        switch offre.moyenTransport {
        case "avion":   return "airplane"
        case "voiture": return "car.fill"
        case "train":   return "tram.fill"
        default:        return "shippingbox.fill"
        }
    }
}
