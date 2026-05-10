import SwiftUI

struct HomeView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<HomeViewModel>()
    private var vm: HomeViewModel? { vmHolder.vm }

    @State private var showCreate           = false
    @State private var showLogin            = false
    @State private var showLoginFavori      = false
    @State private var pendingFavoriId: String? = nil

    let types = [
        ("Tout",      nil as String?),
        ("Transport", "transport"),
        ("Achat",     "achat_transport")
    ]

    var body: some View {
        NavigationStack {
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

                        HStack(spacing: 8) {
                            // Bouton filtre – quad glass
                            Button {
                                vm?.showFiltres = true
                            } label: {
                                let hasFilters = vm?.filtresActifs.isEmpty == false
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(hasFilters ? .appPrimary : .appTextSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .overlay(alignment: .topTrailing) {
                                        if hasFilters {
                                            Circle()
                                                .fill(Color.appPrimary)
                                                .frame(width: 8, height: 8)
                                                .offset(x: 4, y: -4)
                                        }
                                    }
                            }

                            // Bouton + – quad glass + gradient
                            Button {
                                if authState.isLoggedIn { showCreate = true }
                                else { showLogin = true }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 13).fill(.ultraThinMaterial)
                                            RoundedRectangle(cornerRadius: 13).fill(Color.appPrimary)
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 13)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }

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
        }
        .task {
            vmHolder.vm = factory.makeHomeViewModel()
            await vm?.loadPays()
            await vm?.loadFavorisIds(isLoggedIn: authState.isLoggedIn)
            await vm?.loadAnnonces()
        }
    }
}

// ── Panneau filtres avancés – accordion ───────────────────

struct HomeFiltresView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: HomeViewModel

    @State private var openSection: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {

                    accordionCard(
                        "Catégorie", icon: "tag.fill",
                        selectedLabels: vm.filtresCategories.sorted().map { $0.capitalized }
                    ) {
                        MultiSelectSection(
                            title: "",
                            items: HomeViewModel.categoriesDisponibles,
                            selected: $vm.filtresCategories,
                            labelFor: { $0.capitalized }
                        )
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
                                labelFor: { code in vm.pays.first { $0.code == code }?.nom ?? code }
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
                                labelFor: { code in vm.pays.first { $0.code == code }?.nom ?? code }
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

    // ── Labels résumé ─────────────────────────────────────────
    private var departLabels: [String] {
        var items = vm.filtrePaysDepart.sorted()
            .compactMap { code in vm.pays.first { $0.code == code }?.nom }
        if !vm.filtreVilleDepart.isEmpty { items.append(vm.filtreVilleDepart) }
        return items
    }

    private var arriveeLabels: [String] {
        var items = vm.filtrePaysArrivee.sorted()
            .compactMap { code in vm.pays.first { $0.code == code }?.nom }
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

