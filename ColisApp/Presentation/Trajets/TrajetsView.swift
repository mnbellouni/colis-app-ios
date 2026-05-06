import SwiftUI

struct TrajetsView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<TrajetViewModel>()
    private var vm: TrajetViewModel? { vmHolder.vm }

    @State private var showCreate = false
    @State private var showLogin  = false
    @State private var showCertification = false
    @State private var resumeCreateAfterLogin = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────
            VStack(spacing: 12) {
                HStack {
                    Text("Trajets disponibles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Button {
                        Task { await handleCreateTrajetTap() }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(LinearGradient.appPrimary)
                            .cornerRadius(13)
                    }
                }

                // Barre DÉPART / ARRIVÉE
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DÉPART")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.appTextTertiary)
                            .kerning(0.5)
                        TextField("Paris", text: Binding(
                            get: { vm?.searchDepart ?? "" },
                            set: { vm?.searchDepart = $0 }
                        ))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack {
                        Circle()
                            .fill(LinearGradient.appPrimary)
                            .frame(width: 34, height: 34)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ARRIVÉE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.appTextTertiary)
                            .kerning(0.5)
                        TextField("Destination", text: Binding(
                            get: { vm?.searchArrivee ?? "" },
                            set: { vm?.searchArrivee = $0 }
                        ))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        Task { await vm?.appliquerFiltres() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextSecondary)
                            .padding(.leading, 10)
                    }
                }
                .padding(14)
                .background(Color.appCard)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color.appBackground)

            // ── Filtres actifs ────────────────────────────
            if let vm, !vm.filtresActifs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.filtresActifs, id: \.label) { filtre in
                            HStack(spacing: 4) {
                                Text(filtre.label)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.appPrimary)
                                Button { filtre.clear() } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.appPrimary.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.appPrimaryLight)
                            .cornerRadius(99)
                        }
                        Button { vm.clearAllFilters() } label: {
                            Text("Tout effacer")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appError)
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .padding(.vertical, 8)
                .background(Color.appBackground)
            }

            // ── Contenu ───────────────────────────────────
            if vm?.isLoading == true {
                Spacer()
                ProgressView().tint(.appPrimary)
                Spacer()
            } else if vm?.trajetsFiltres.isEmpty == true {
                Spacer()
                EmptyStateView(
                    icon:    "airplane",
                    title:   "Aucun trajet",
                    message: "Soyez le premier à proposer un trajet !"
                )
                Spacer()
            } else {
                ScrollView {
                    let count = vm?.trajetsFiltres.count ?? 0
                    HStack {
                        Text("\(count) trajet\(count > 1 ? "s" : "") trouvé\(count > 1 ? "s" : "")")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Button { vm?.showFilters = true } label: {
                            Text("Filtrer")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.appPrimaryLight)
                                .cornerRadius(99)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    LazyVStack(spacing: 12) {
                        ForEach(vm?.trajetsFiltres ?? []) { trajet in
                            NavigationLink(value: trajet.id) {
                                TrajetCard(trajet: trajet)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)

                }
                .refreshable { await vm?.loadTrajets() }
            }
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .navigationDestination(for: String.self) { TrajetDetailView(trajetId: $0) }
        .sheet(isPresented: $showCreate) {
            if let vm {
                CreateTrajetView(vm: vm)
            }
        }
        .sheet(isPresented: $showLogin)  { AuthNavigationView() }
        .sheet(isPresented: $showCertification) {
            CertificationFlowView(
                accountNom: authState.userNom ?? "",
                accountPrenom: authState.userPrenom ?? "",
                source: "Trajets"
            )
        }
        .sheet(isPresented: Binding(get: { vm?.showFilters ?? false }, set: { vm?.showFilters = $0 })) {
            if let vm {
                TrajetFiltresView(vm: vm)
            }
        }
        .onChange(of: authState.isLoggedIn) { isLoggedIn in
            guard isLoggedIn, resumeCreateAfterLogin else { return }
            resumeCreateAfterLogin = false
            Task {
                await handleCreateTrajetTap()
            }
        }
        .task {
            vmHolder.vm = factory.makeTrajetViewModel()
            await vm?.loadTrajets()
        }
    }

    private func handleCreateTrajetTap() async {
        guard authState.isLoggedIn else {
            resumeCreateAfterLogin = true
            showLogin = true
            return
        }

        guard let userId = authState.userId else {
            showLogin = true
            return
        }

        let checker = factory.makeProfileViewModel()
        await checker.loadProfile(userId: userId)

        if checker.user?.verified == true {
            showCreate = true
        } else {
            showCertification = true
        }
    }
}

// ── Carte Trajet ──────────────────────────────────────────
struct TrajetCard: View {
    let trajet: Trajet

    var body: some View {
        VStack(spacing: 12) {

            HStack(alignment: .center, spacing: 10) {
                AvatarView(seed: trajet.voyageurId, size: 44, showOnline: true)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(String(trajet.voyageurId.prefix(8)))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                            .lineLimit(1)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.appPrimary)
                    }
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "F59E0B"))
                        }
                        Text("4.9")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextTertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(String(format: "%.0f", trajet.prixParKg))€")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.appPrimary)
                    Text("par kg")
                        .font(.system(size: 10))
                        .foregroundColor(.appTextTertiary)
                }
            }

            RouteLineView(depart: trajet.villeDepart, arrivee: trajet.villeArrivee, moyen: trajet.moyenTransport)

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.appBorder).frame(height: 5)
                            RoundedRectangle(cornerRadius: 3).fill(Color.appPrimary)
                                .frame(width: geo.size.width * CGFloat(min(trajet.poidsRestant / max(trajet.poidsDisponible, 0.1), 1.0)), height: 5)
                        }
                    }
                    .frame(height: 5)
                    Text("\(String(format: "%.0f", trajet.poidsRestant)) kg restants / \(String(format: "%.0f", trajet.poidsDisponible)) kg")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextTertiary)
                }
                Text(formattedDate(trajet.dateDepart))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.appCanvas)
                    .cornerRadius(99)
                    .fixedSize()
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 2)
    }

    private func formattedDate(_ iso: String) -> String {
        let parts = String(iso.prefix(10)).split(separator: "-")
        guard parts.count == 3, let day = parts.last, let month = Int(parts[1]), month >= 1, month <= 12 else { return String(iso.prefix(10)) }
        return "\(day) \(["jan","fév","mar","avr","mai","jun","jul","aoû","sep","oct","nov","déc"][month - 1])"
    }
}

// ── Ligne de route ────────────────────────────────────────
struct RouteLineView: View {
    let depart: String; let arrivee: String; let moyen: String

    var body: some View {
        HStack(spacing: 0) {
            Text(depart).font(.system(size: 13, weight: .semibold)).foregroundColor(.appTextPrimary).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
            Rectangle().fill(Color.appPrimary).frame(maxWidth: .infinity).frame(height: 1.5)
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(.appPrimary).padding(.horizontal, 6)
            Rectangle().fill(Color.appAccent.opacity(0.6)).frame(maxWidth: .infinity).frame(height: 1.5)
            Text(arrivee).font(.system(size: 13, weight: .semibold)).foregroundColor(.appTextPrimary).lineLimit(1).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 10).padding(.horizontal, 12)
        .background(Color.appCanvas).cornerRadius(10)
    }

    private var icon: String {
        switch moyen { case "avion": return "airplane"; case "voiture": return "car.fill"; case "train": return "tram.fill"; case "bateau": return "ferry.fill"; default: return "paperplane.fill" }
    }
}

// ── Filtres avancés ───────────────────────────────────────
struct TrajetFiltresView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: TrajetViewModel
    let moyens     = ["avion","voiture","train","bus","moto","bateau"]
    let categories = ["vetements","electronique","medicament","documents","alimentaire","cosmetique","cadeau","autre"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AppTextField(title: "Ville de départ",  placeholder: "Paris",      text: $vm.filtreVilleDepart)
                    AppTextField(title: "Ville d'arrivée",  placeholder: "Casablanca", text: $vm.filtreVilleArrivee)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date de départ").font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
                        DatePicker("", selection: Binding(get: { vm.filtreDate ?? Date() }, set: { vm.filtreDate = $0 }), displayedComponents: .date).labelsHidden()
                    }
                    chipSection("Catégorie", items: categories, sel: { vm.filtreCategorie == $0 }) { vm.filtreCategorie = (vm.filtreCategorie == $0) ? "" : $0 }
                    chipSection("Transport", items: moyens, sel: { vm.filtreMoyen == $0 }) { vm.filtreMoyen = (vm.filtreMoyen == $0) ? "" : $0 }
                    HStack(spacing: 12) {
                        AppTextField(title: "Poids min (kg)",  placeholder: "5",  text: $vm.filtrePoidsMin, keyboardType: .decimalPad)
                        AppTextField(title: "Prix max (€/kg)", placeholder: "10", text: $vm.filtrePrixMax,  keyboardType: .decimalPad)
                    }
                    AppButton(title: "Appliquer les filtres") { Task { await vm.appliquerFiltres() }; dismiss() }
                    Button { vm.clearAllFilters(); dismiss() } label: {
                        Text("Réinitialiser").font(.system(size: 15, weight: .medium)).foregroundColor(.appError)
                    }
                }
                .padding(18)
            }
            .background(Color.appBackground)
            .navigationTitle("Filtres avancés").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Fermer") { dismiss() }.foregroundColor(.appPrimary) } }
        }
    }

    @ViewBuilder
    private func chipSection(_ title: String, items: [String], sel: @escaping (String) -> Bool, onTap: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        FilterChip(label: item.capitalized, isSelected: sel(item)) { onTap(item) }
                    }
                }
            }
        }
    }
}
