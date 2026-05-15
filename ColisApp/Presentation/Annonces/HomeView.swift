import SwiftUI

struct HomeView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var configService: AppConfigService

    @StateObject private var vmHolder = VMHolder<HomeViewModel>()
    private var vm: HomeViewModel? { vmHolder.vm }

    @State private var showCreate           = false
    @State private var showLogin            = false
    @State private var showLoginFavori      = false
    @State private var showSearch           = false
    @State private var pendingFavoriId: String? = nil

    @Binding var selectedTab: Int

    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }

    let types = [
        ("Tout",      nil as String?),
        ("Transport", "transport"),
        ("Achat",     "achat_transport")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {

                // ── Header ────────────────────────────────
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bonjour, \(authState.userPrenom ?? "👋")")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                            Text("Trouvez un voyageur")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                        }
                        Spacer()

                        // Avatar profil (si connecté)
                        if authState.isLoggedIn {
                            Button {
                                selectedTab = 3
                            } label: {
                                AvatarView(
                                    seed: authState.userPrenom ?? "Utilisateur",
                                    size: 42,
                                    showOnline: false
                                )
                            }
                        }
                    }

                    // ── Barre de recherche ────────────────
                    HStack(spacing: 10) {
                        Button {
                            showSearch = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 17))
                                    .foregroundColor(.appTextTertiary)

                                Text("Ville, pays, mot-clé…")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextTertiary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            vm?.showFiltres = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appPrimary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.appPrimaryLight)
                                    .cornerRadius(10)

                                if vm?.filtresActifs.isEmpty == false {
                                    Circle()
                                        .fill(Color.appAccent)
                                        .frame(width: 7, height: 7)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                        .offset(x: 3, y: 3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.appCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.appBorder, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)

                    // ── Filtres rapides type ──────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(types, id: \.0) { label, type in
                                FilterChip(label: label, isSelected: vm?.selectedType == type, glass: false) {
                                    guard let vm else { return }
                                    vm.selectedType = type
                                    Task { await vm.loadAnnonces(type: type) }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color.appBackground)

                // ── Filtres actifs ────────────────────────
                if let vm, !vm.filtresActifs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.filtresActifs, id: \.label) { filtre in
                                HStack(spacing: 4) {
                                    Text(filtre.label)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.appPrimary)
                                    Button { filtre.clear(); Task { await vm.appliquerFiltres() } } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.appPrimary.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.appPrimaryLight)
                                .cornerRadius(99)
                            }
                            Button { vm.clearAllFilters(); Task { await vm.loadAnnonces() } } label: {
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

                // ── Contenu ───────────────────────────────
                if vm?.isLoading != false {
                    Spacer()
                    ProgressView().tint(.appPrimary)
                    Spacer()
                } else if let error = vm?.error {
                    Spacer()
                    VStack(spacing: 12) {
                        EmptyStateView(icon: "wifi.slash", title: "Erreur", message: error)
                        Button { Task { await vm?.loadAnnonces() } } label: {
                            Text("Réessayer")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appPrimary)
                        }
                    }
                    Spacer()
                } else if vm?.annonces.isEmpty == true {
                    Spacer()
                    EmptyStateView(icon: "shippingbox", title: "Aucune annonce",
                                   message: "Soyez le premier à publier !")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm?.annonces ?? []) { annonce in
                                NavigationLink {
                                    AnnonceDetailView(annonceId: annonce.id)
                                } label: {
                                    AnnonceCard(
                                        annonce: annonce,
                                        isFavori: vm?.idsFavoris.contains(annonce.id) ?? false,
                                        onFavoriTap: {
                                            if authState.isLoggedIn {
                                                Task { await vm?.toggleFavori(annonceId: annonce.id) }
                                            } else {
                                                pendingFavoriId = annonce.id
                                                showLoginFavori = true
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if annonce.id == vm?.annonces.last?.id {
                                        Task { await vm?.loadMore() }
                                    }
                                }
                            }
                            if vm?.isLoadingMore == true {
                                ProgressView().tint(.appPrimary).padding(.vertical, 8)
                            }
                        }
                        .padding(16)
                    }
                    .refreshable { await vm?.loadAnnonces(type: vm?.selectedType) }
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)

            // ── FAB Créer annonce ─────────────────────────
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        if authState.isLoggedIn { showCreate = true }
                        else { showLogin = true }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appPrimaryDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.appPrimary.opacity(0.45), radius: 18, x: 0, y: 6)
                    }
                    .buttonStyle(FabButtonStyle())
                    .padding(.trailing, 18)
                    .padding(.bottom, 16)
                }
            }
        }
            .sheet(isPresented: $showCreate) { CreateAnnonceView() }
            .sheet(isPresented: $showLogin)  { AuthNavigationView(onAuthenticated: { showCreate = true }) }
            .sheet(isPresented: $showLoginFavori) {
                AuthNavigationView(onAuthenticated: {
                    let id = pendingFavoriId
                    pendingFavoriId = nil
                    Task {
                        await vm?.loadFavorisIds(isLoggedIn: true)
                        if let id { await vm?.toggleFavori(annonceId: id) }
                    }
                })
            }
            .sheet(isPresented: Binding(
                get: { vm?.showFiltres ?? false },
                set: { vm?.showFiltres = $0 }
            )) {
                if let vm { HomeFiltresView(vm: vm) }
            }
            .navigationDestination(isPresented: $showSearch) {
                SearchView()
            }
        }
        .task {
            vmHolder.vm = factory.makeHomeViewModel()
            vm?.loadPays(from: configService.config)
            await vm?.loadFavorisIds(isLoggedIn: authState.isLoggedIn)
            await vm?.loadAnnonces()
        }
    }
}

// ── Panneau filtres avancés – accordion ───────────────────

struct HomeFiltresView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var configService: AppConfigService
    @ObservedObject var vm: HomeViewModel

    @State private var openSection: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {

                    accordionCard(
                        "Tags", icon: "sparkles",
                        selectedLabels: tagsLabels
                    ) {
                        tagsSection
                    }

                    accordionCard(
                        "Départ", icon: "airplane.departure",
                        selectedLabels: departLabels
                    ) {
                        VStack(spacing: 14) {
                            MultiSelectSection(
                                title: "Pays de départ",
                                items: vm.pays.map { $0.code },
                                selected: $vm.filtrePaysDepart,
                                labelFor: { code in vm.pays.first { $0.code == code }?.affichage ?? code }
                            )
                            AppTextField(title: "Ville", placeholder: "Paris",
                                         text: $vm.filtreVilleDepart)
                        }
                    }

                    accordionCard(
                        "Arrivée", icon: "airplane.arrival",
                        selectedLabels: arriveeLabels
                    ) {
                        VStack(spacing: 14) {
                            MultiSelectSection(
                                title: "Pays d'arrivée",
                                items: vm.pays.map { $0.code },
                                selected: $vm.filtrePaysArrivee,
                                labelFor: { code in vm.pays.first { $0.code == code }?.affichage ?? code }
                            )
                            AppTextField(title: "Ville", placeholder: "Casablanca",
                                         text: $vm.filtreVilleArrivee)
                        }
                    }

                    accordionCard(
                        "Options", icon: "slider.horizontal.3",
                        selectedLabels: optionsLabels
                    ) {
                        VStack(spacing: 14) {
                            Toggle(isOn: $vm.filtreUrgence) {
                                Label("Urgentes uniquement", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 15)).foregroundColor(.appTextPrimary)
                            }
                            .tint(.appPrimary)
                            Toggle(isOn: $vm.filtreFavoris) {
                                Label("Mes favoris", systemImage: "heart.fill")
                                    .font(.system(size: 15)).foregroundColor(.appTextPrimary)
                            }
                            .tint(.appError)
                        }
                    }

                    VStack(spacing: 12) {
                        AppButton(title: "Appliquer les filtres") {
                            Task { await vm.appliquerFiltres() }
                            dismiss()
                        }
                        Button {
                            vm.clearAllFilters()
                            Task { await vm.loadAnnonces() }
                            dismiss()
                        } label: {
                            Text("Réinitialiser")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.appError)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(18)
            }
            .background(Color.appBackground)
            .navigationTitle("Filtres avancés")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton { dismiss() }
                }
            }
        }
    }

    // ── Section tags groupés ──────────────────────────────────
    @ViewBuilder
    private var tagsSection: some View {
        let config = configService.config.tags
        VStack(alignment: .leading, spacing: 14) {
            tagGroupe("Urgence", items: config.urgence)
            tagGroupe("Contenu", items: config.contenu)
            tagGroupe("Dimensions", items: config.dimensions)
        }
    }

    @ViewBuilder
    private func tagGroupe(_ titre: String, items: [TagItem]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(titre)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
                    .textCase(.uppercase)
                FlowLayout(spacing: 6) {
                    ForEach(items) { item in
                        let selected = vm.filtreTags.contains(item.id)
                        FilterChip(label: item.label, isSelected: selected) {
                            if selected { vm.filtreTags.remove(item.id) }
                            else        { vm.filtreTags.insert(item.id) }
                        }
                    }
                }
            }
        }
    }

    // ── Labels résumé ─────────────────────────────────────────
    private var tagsLabels: [String] {
        let allTags = configService.config.tags.tous
        return vm.filtreTags.sorted()
            .compactMap { id in allTags.first { $0.id == id }?.label }
    }

    private var departLabels: [String] {
        var items = vm.filtrePaysDepart.sorted()
            .compactMap { code in vm.pays.first { $0.code == code }.map { "\($0.emoji) \($0.nom)" } }
        if !vm.filtreVilleDepart.isEmpty { items.append(vm.filtreVilleDepart) }
        return items
    }

    private var arriveeLabels: [String] {
        var items = vm.filtrePaysArrivee.sorted()
            .compactMap { code in vm.pays.first { $0.code == code }.map { "\($0.emoji) \($0.nom)" } }
        if !vm.filtreVilleArrivee.isEmpty { items.append(vm.filtreVilleArrivee) }
        return items
    }

    private var optionsLabels: [String] {
        [vm.filtreUrgence ? "Urgent" : nil,
         vm.filtreFavoris ? "Favoris" : nil].compactMap { $0 }
    }

    // ── Accordion card ────────────────────────────────────────
    @ViewBuilder
    private func accordionCard<Content: View>(
        _ title: String,
        icon: String,
        selectedLabels: [String],
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isOpen    = openSection == title
        let hasValue  = !selectedLabels.isEmpty
        VStack(spacing: 0) {

            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    openSection = isOpen ? nil : title
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isOpen || hasValue ? .appPrimary : .appTextSecondary)
                        .frame(width: 18)
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appTextTertiary)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                        .animation(.easeInOut(duration: 0.22), value: isOpen)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, hasValue && !isOpen ? 8 : 14)
                .contentShape(Rectangle())
            }

            // Résumé des sélections (visible uniquement quand fermé)
            if hasValue && !isOpen {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(selectedLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.appPrimaryLight)
                                .cornerRadius(AppRadius.pill)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)
                .transition(.opacity)
            }

            // Contenu (visible quand ouvert)
            if isOpen {
                Divider().padding(.horizontal, 16)
                content()
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.appCard)
        .cornerRadius(13)
        .overlay(RoundedRectangle(cornerRadius: 13)
            .stroke(isOpen ? Color.appPrimary.opacity(0.3) : Color.appBorder,
                    lineWidth: isOpen ? 1.5 : 1))
        .clipped()
    }
}

// ── Single-select section ─────────────────────────────────

private struct SingleSelectSection: View {
    let title: String
    let items: [String]
    @Binding var selected: String?
    let labelFor: (String) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }

            VStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    let isSelected = selected == item
                    Button {
                        selected = isSelected ? nil : item
                    } label: {
                        HStack {
                            Text(labelFor(item))
                                .font(.system(size: 15))
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundColor(isSelected ? .appPrimary : .appBorder)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    if item != items.last {
                        Divider().padding(.leading, 14)
                    }
                }
            }
            .background(Color.appCanvas)
            .cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1.5))
        }
    }
}

// ── FAB Button Style ──────────────────────────────────────
struct FabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// ── Multi-select section ──────────────────────────────────

private struct MultiSelectSection: View {
    let title: String
    let items: [String]
    @Binding var selected: Set<String>
    let labelFor: (String) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }

            VStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    let isSelected = selected.contains(item)
                    Button {
                        if isSelected { selected.remove(item) }
                        else { selected.insert(item) }
                    } label: {
                        HStack {
                            Text(labelFor(item))
                                .font(.system(size: 15))
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundColor(isSelected ? .appPrimary : .appBorder)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    if item != items.last {
                        Divider().padding(.leading, 14)
                    }
                }
            }
            .background(Color.appCanvas)
            .cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1.5))
        }
    }
}


