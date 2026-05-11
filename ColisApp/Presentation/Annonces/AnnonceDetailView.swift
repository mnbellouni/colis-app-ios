import SwiftUI

struct AnnonceDetailView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)        private var dismiss

    let annonceId: String

    @StateObject private var vmHolder = VMHolder<AnnonceDetailViewModel>()
    private var vm: AnnonceDetailViewModel? { vmHolder.vm }

    @State private var showOffreSheet          = false
    @State private var showLogin               = false
    @State private var showLoginFavori         = false
    @State private var showCertificationAlert  = false
    @State private var showTrajetAlert         = false
    @State private var showCertificationSheet  = false
    @State private var showCreateTrajetSheet   = false
    @State private var showChat                = false
    @State private var showFermerAlert         = false
    @State private var showPourvueSheet        = false

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
                        HStack(alignment: .center, spacing: 12) {

                            // Départ
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Départ")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                Text(annonce.paysDepart.flagEmoji)
                                    .font(.system(size: 22))
                                Text(annonce.villeDepart)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                    .lineLimit(1)
                            }

                            // Connecteur
                            HStack(spacing: 0) {
                                Circle().fill(Color.appPrimary).frame(width: 7, height: 7)
                                Rectangle().fill(Color.appBorder).frame(height: 1)
                                Image(systemName: "airplane")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appPrimary)
                                    .padding(.horizontal, 4)
                                Rectangle().fill(Color.appBorder).frame(height: 1)
                                Circle().fill(Color.appSuccess).frame(width: 7, height: 7)
                            }
                            .frame(maxWidth: .infinity)

                            // Arrivée
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Arrivée")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                Text((annonce.paysArrivee ?? "").flagEmoji)
                                    .font(.system(size: 22))
                                Text(annonce.villeArrivee ?? "–")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(16)
                        .background(Color.appBackground)
                        .cornerRadius(13)

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
        .sheet(isPresented: $showLogin) {
            AuthNavigationView(onAuthenticated: {
                if authState.certificationStatus != "verifie" {
                    showCertificationAlert = true
                } else if vm?.userHasTrajets != true {
                    showTrajetAlert = true
                } else {
                    showOffreSheet = true
                }
            })
        }
        .sheet(isPresented: $showLoginFavori) {
            AuthNavigationView(onAuthenticated: {
                Task {
                    if let id = vm?.annonce?.id {
                        await vm?.toggleFavori(annonceId: id)
                    }
                }
            })
        }
        .sheet(isPresented: $showCertificationSheet) {
            CertificationFlowView(
                accountNom:    authState.userNom    ?? "",
                accountPrenom: authState.userPrenom ?? "",
                source:        "annonce_detail"
            )
        }
        .sheet(isPresented: $showCreateTrajetSheet) {
            CreateTrajetView(vm: factory.makeTrajetViewModel())
        }
        .navigationDestination(isPresented: $showChat) {
            if let annonce = vm?.annonce {
                ChatView(
                    conversationId: [authState.userId ?? "", annonce.demandeurId]
                        .sorted().joined(separator: "_"),
                    autreUserId: annonce.demandeurId
                )
            }
        }
        .alert("Certification requise", isPresented: $showCertificationAlert) {
            Button("Me certifier") { showCertificationSheet = true }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Vous devez être certifié pour faire une offre ou contacter un annonceur.")
        }
        .alert("Trajet requis", isPresented: $showTrajetAlert) {
            Button("Créer un trajet") { showCreateTrajetSheet = true }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Vous devez avoir un trajet actif pour faire une offre ou contacter un annonceur.")
        }
        .alert("Fermer l'annonce", isPresented: $showFermerAlert) {
            Button("Fermer", role: .destructive) {
                Task { await vm?.fermerAnnonce() }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("L'annonce ne sera plus visible pour les voyageurs.")
        }
        .sheet(isPresented: $showPourvueSheet) {
            if let annonce = vm?.annonce {
                PourvueSheet(
                    offres: vm?.offres ?? [],
                    demandeurId: annonce.demandeurId,
                    onConfirm: { conversationId in
                        Task { await vm?.marquerPourvue(conversationId: conversationId) }
                    }
                )
            }
        }
        .alert("Erreur", isPresented: .constant(vm?.error != nil)) {
            Button("OK") { vm?.error = nil }
        } message: {
            if let e = vm?.error { Text(e) }
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
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            photoPlaceholder(annonce)
                        }
                    }
                    .clipped()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: annonce.photos.count > 1 ? .always : .never))
            .frame(height: 220)
        } else {
            photoPlaceholder(annonce)
                .frame(height: 220)
        }
    }

    private func photoPlaceholder(_ annonce: Annonce) -> some View {
        ZStack {
            Color.appPrimaryLight
            VStack(spacing: 8) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 52))
                    .foregroundColor(.appPrimary.opacity(0.35))
                Text(annonce.categories.first.map { $0.replacingOccurrences(of: "_", with: " ").capitalized } ?? "Colis")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appPrimary.opacity(0.5))
            }
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
            .cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
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
        let user        = vm?.annonceur
        let evals       = vm?.evaluationsAnnonceur
        let displayName = user?.nomComplet ?? String(annonce.demandeurId.prefix(8))
        let note        = evals?.moyenne ?? user?.noteExpediteur ?? 0
        let nbAvis      = evals?.total ?? 0

        NavigationLink {
            AnnonceurProfilView(userId: annonce.demandeurId)
        } label: {
            VStack(alignment: .leading, spacing: 12) {

                Text("Annonceur")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appTextSecondary)

                HStack(spacing: 12) {
                    AvatarView(seed: annonce.demandeurId, size: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(displayName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            if user?.verified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.appPrimary)
                            }
                        }
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { i in
                                Image(systemName: Double(i) < note ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(.appWarning)
                            }
                            Text(nbAvis > 0 ? "(\(nbAvis) avis)" : "Aucun avis")
                                .font(.system(size: 11))
                                .foregroundColor(.appTextTertiary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextTertiary)
                }

                if let comment = evals?.items.first?.commentaire, !comment.isEmpty {
                    Text("\"\(comment)\"")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                        .italic()
                        .lineLimit(2)
                }
            }
            .padding(14)
            .background(Color.appCard)
            .cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // ── Boutons d'action ────────────────────────────────────
    @ViewBuilder
    private func actionButtons(_ annonce: Annonce) -> some View {
        let isOwner     = annonce.demandeurId == authState.userId
        let isOuverte   = annonce.statut == "ouverte"
        let isCertified = authState.certificationStatus == "verifie"
        let hasTrajets  = vm?.userHasTrajets == true

        if isOwner {
            if isOuverte {
                AppButton(title: "Marquer comme pourvue") {
                    showPourvueSheet = true
                }
                Button {
                    showFermerAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark.circle").font(.system(size: 14))
                        Text("Fermer l'annonce").font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    .foregroundColor(.appError)
                    .frame(height: 52)
                    .background(Color.appErrorLight)
                    .cornerRadius(13)
                }
                .buttonStyle(.plain)
            }
        } else if isOuverte {
            if authState.isLoggedIn {
                AppButton(title: "Faire une offre") {
                    if !isCertified {
                        showCertificationAlert = true
                    } else if !hasTrajets {
                        showTrajetAlert = true
                    } else {
                        showOffreSheet = true
                    }
                }

                Button {
                    if !isCertified {
                        showCertificationAlert = true
                    } else if !hasTrajets {
                        showTrajetAlert = true
                    } else {
                        showChat = true
                    }
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "message.fill").font(.system(size: 14))
                        Text("Contacter l'annonceur").font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    .foregroundColor(.appPrimary)
                    .frame(height: 52)
                    .background(Color.appCard)
                    .cornerRadius(13)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.appPrimary, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
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

// ── Feuille de sélection pour "pourvue" ───────────────────
struct PourvueSheet: View {
    let offres: [Offre]
    let demandeurId: String
    let onConfirm: (String?) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        onConfirm(nil)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.appSuccess)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Marquer sans lien")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.appTextPrimary)
                                Text("Sans associer une conversation spécifique")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                if !offres.isEmpty {
                    Section("Associer à une offre reçue") {
                        ForEach(offres) { offre in
                            let conversationId = [demandeurId, offre.voyageurId].sorted().joined(separator: "_")
                            Button {
                                onConfirm(conversationId)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    AvatarView(seed: offre.voyageurId, size: 36)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(offre.villeDepart) → \(offre.villeArrivee)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.appTextPrimary)
                                        Text(offre.message.isEmpty ? "Offre sans message" : offre.message)
                                            .font(.system(size: 12))
                                            .foregroundColor(.appTextSecondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text("\(Int(offre.fraisService)) €")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.appPrimary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Marquer comme pourvue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { CloseButton { dismiss() } }
            }
        }
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
