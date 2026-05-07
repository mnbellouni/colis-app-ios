import SwiftUI

struct AnnonceDetailView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)        private var dismiss

    let annonceId: String

    @StateObject private var vmHolder = VMHolder<AnnonceDetailViewModel>()
    private var vm: AnnonceDetailViewModel? { vmHolder.vm }

    @State private var showOffreSheet   = false
    @State private var showLogin        = false
    @State private var showLoginFavori  = false
    @State private var certificationError: String? = nil

    var body: some View {
        ScrollView {
            if let annonce = vm?.annonce {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Photos ────────────────────────────
                    photosSection(annonce)

                    VStack(alignment: .leading, spacing: 20) {

                        // ── Titre + Budget ────────────────
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(annonce.titre)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                HStack(spacing: 6) {
                                    StatutBadge(statut: annonce.statut)
                                    typeBadge(annonce)
                                    if annonce.isBoosted {
                                        Text("⭐ Boosté")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.appWarning)
                                            .padding(.horizontal, 8).padding(.vertical, 3)
                                            .background(Color.appWarningLight)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(Int(annonce.budgetTransport)) €")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.appPrimary)
                                if !annonce.dateLimite.isEmpty {
                                    Text("Avant le \(formattedDate(annonce.dateLimite))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.appTextTertiary)
                                }
                            }
                        }

                        // ── Itinéraire ────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Itinéraire")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appTextSecondary)

                            HStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Circle().fill(Color.appPrimary).frame(width: 10, height: 10)
                                    Rectangle().fill(Color.appBorder).frame(width: 1, height: 28)
                                    Circle().fill(Color.appSuccess).frame(width: 10, height: 10)
                                }
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("\(annonce.paysDepart.flagEmoji) \(annonce.villeDepart)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.appTextPrimary)
                                    Text("\((annonce.paysArrivee ?? "").flagEmoji) \(annonce.villeArrivee ?? "")")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.appTextPrimary)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.appBackground)
                        .cornerRadius(12)

                        // ── Détails poids / catégorie / fragile ──
                        HStack(spacing: 10) {
                            DetailItem(icon: "scalemass",
                                       label: "Poids",
                                       value: "\(String(format: "%.1f", annonce.poids)) kg")
                            DetailItem(icon: "tag",
                                       label: "Catégorie",
                                       value: annonce.categories.map { $0.capitalized }.joined(separator: ", ").isEmpty
                                           ? "—"
                                           : annonce.categories.map { $0.capitalized }.joined(separator: ", "))
                            if annonce.fragile {
                                DetailItem(icon: "exclamationmark.triangle.fill",
                                           label: "Fragile",
                                           value: "Oui")
                            }
                        }

                        // ── Section achat (achat_transport) ──
                        if annonce.isAchat, let achat = annonce.achat {
                            achatSection(achat)
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

                        // ── Annonceur ─────────────────────
                        annonceurSection(annonce)

                        // ── Boutons action ────────────────
                        actionButtons(annonce)
                    }
                    .padding(18)
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
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if authState.isLoggedIn {
                    Button {
                        Task {
                            if let id = vm?.annonce?.id {
                                await vm?.toggleFavori(annonceId: id)
                            }
                        }
                    } label: {
                        Image(systemName: vm?.isFavori == true ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(vm?.isFavori == true ? .appError : .appTextSecondary)
                    }
                } else {
                    Button { showLoginFavori = true } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 18))
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showOffreSheet) {
            if let vm { CreateOffreView(annonceId: annonceId, vm: vm) }
        }
        .sheet(isPresented: $showLogin)       { AuthNavigationView() }
        .sheet(isPresented: $showLoginFavori) { AuthNavigationView() }
        .alert("Certification requise", isPresented: .constant(certificationError != nil)) {
            Button("OK") { certificationError = nil }
        } message: {
            if let e = certificationError { Text(e) }
        }
        .task {
            vmHolder.vm = factory.makeAnnonceDetailViewModel()
            await vm?.load(id: annonceId, isLoggedIn: authState.isLoggedIn)
        }
    }

    // ── Photos ──────────────────────────────────────────────
    @ViewBuilder
    private func photosSection(_ annonce: Annonce) -> some View {
        if !annonce.photos.isEmpty {
            TabView {
                ForEach(annonce.photos.prefix(2), id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { Color.appBackground }
                    .clipped()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: annonce.photos.count > 1 ? .always : .never))
            .frame(height: 220)
        } else {
            ZStack {
                Color.appPrimaryLight
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary.opacity(0.4))
            }
            .frame(height: 160)
        }
    }

    // ── Badge type ──────────────────────────────────────────
    @ViewBuilder
    private func typeBadge(_ annonce: Annonce) -> some View {
        Text(annonce.isAchat ? "Achat + Transport" : "Transport")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.appAccent)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Color.appAccent.opacity(0.12))
            .cornerRadius(20)
    }

    // ── Section produit à acheter ───────────────────────────
    @ViewBuilder
    private func achatSection(_ achat: Achat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Produit à acheter")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)

            VStack(alignment: .leading, spacing: 8) {
                achatRow(label: "Produit",  value: achat.nomProduit)
                if !achat.magasin.isEmpty {
                    achatRow(label: "Magasin", value: achat.magasin)
                }
                achatRow(label: "Prix",
                         value: "\(String(format: "%.2f", achat.prixObjet)) \(achat.deviseObjet)")
                if !achat.instructions.isEmpty {
                    achatRow(label: "Instructions", value: achat.instructions)
                }
                if !achat.urlProduit.isEmpty, let url = URL(string: achat.urlProduit) {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                            Text("Voir le produit")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appPrimary)
                    }
                }
            }
            .padding(14)
            .background(Color.appCard)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appBorder, lineWidth: 1))
        }
    }

    private func achatRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13)).foregroundColor(.appTextSecondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .medium)).foregroundColor(.appTextPrimary)
        }
    }

    // ── Annonceur ───────────────────────────────────────────
    @ViewBuilder
    private func annonceurSection(_ annonce: Annonce) -> some View {
        HStack(spacing: 12) {
            AvatarView(seed: annonce.demandeurId, size: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text("Annonceur")
                    .font(.system(size: 12)).foregroundColor(.appTextTertiary)
                NavigationLink(value: annonce.demandeurId) {
                    HStack(spacing: 4) {
                        Text(String(annonce.demandeurId.prefix(8)))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appPrimary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10)).foregroundColor(.appPrimary)
                    }
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appBorder, lineWidth: 1))
    }

    // ── Boutons d'action ────────────────────────────────────
    @ViewBuilder
    private func actionButtons(_ annonce: Annonce) -> some View {
        let isOwner     = annonce.demandeurId == authState.userId
        let isOuverte   = annonce.statut == "ouverte"
        let isCertified = authState.certificationStatus == "verifie"

        if !isOwner && isOuverte {
            if authState.isLoggedIn {
                AppButton(title: "Faire une offre") {
                    if isCertified {
                        showOffreSheet = true
                    } else {
                        certificationError = "Vous devez être certifié pour faire une offre. Complétez votre certification depuis votre profil."
                    }
                }

                NavigationLink {
                    ChatView(
                        conversationId: [authState.userId ?? "", annonce.demandeurId]
                            .sorted().joined(separator: "_"),
                        autreUserId: annonce.demandeurId
                    )
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "message.fill").font(.system(size: 14))
                        Text("Contacter l'annonceur").font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    .foregroundColor(isCertified ? .appPrimary : .appTextTertiary)
                    .frame(height: 52)
                    .background(isCertified ? Color.appCard : Color.appBackground)
                    .cornerRadius(13)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(isCertified ? Color.appPrimary : Color.appBorder, lineWidth: 1.5)
                    )
                }
                .disabled(!isCertified)
            } else {
                AppButton(title: "Connectez-vous pour faire une offre", action: { showLogin = true }, style: .secondary)
            }
        }
    }

    private func formattedDate(_ iso: String) -> String {
        let parts = String(iso.prefix(10)).split(separator: "-")
        guard parts.count == 3,
              let day = parts.last,
              let month = Int(parts[1]),
              month >= 1, month <= 12
        else { return String(iso.prefix(10)) }
        let mois = ["jan","fév","mar","avr","mai","jun","jul","aoû","sep","oct","nov","déc"]
        return "\(day) \(mois[month - 1])"
    }
}

// ── Composants ────────────────────────────────────────────

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
                .multilineTextAlignment(.center)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.appCard)
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
        .background(Color.appCard)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBorder, lineWidth: 1))
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
