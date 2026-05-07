import SwiftUI

struct HomeView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<HomeViewModel>()
    private var vm: HomeViewModel? { vmHolder.vm }

    @State private var showCreate = false
    @State private var showLogin  = false

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
                            Button {
                                vm?.showFiltres = true
                            } label: {
                                Image(systemName: vm?.filtresActifs.isEmpty == false
                                      ? "line.3.horizontal.decrease.circle.fill"
                                      : "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(vm?.filtresActifs.isEmpty == false ? .appPrimary : .appTextSecondary)
                            }

                            Button {
                                if authState.isLoggedIn { showCreate = true }
                                else { showLogin = true }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(LinearGradient.appPrimary)
                                    .cornerRadius(13)
                            }
                        }
                    }

                    // ── Filtres rapides type ──────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(types, id: \.0) { label, type in
                                FilterChip(label: label, isSelected: vm?.selectedType == type) {
                                    vm?.selectedType = type
                                    Task { await vm?.loadAnnonces(type: type) }
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
                if vm?.isLoading == true {
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
                                    AnnonceCard(annonce: annonce)
                                }
                                .buttonStyle(.plain)
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
            .sheet(isPresented: $showLogin)  { AuthNavigationView() }
            .sheet(isPresented: Binding(
                get: { vm?.showFiltres ?? false },
                set: { vm?.showFiltres = $0 }
            )) {
                if let vm { HomeFiltresView(vm: vm) }
            }
        }
        .task {
            vmHolder.vm = factory.makeHomeViewModel()
            await vm?.loadFavorisIds(isLoggedIn: authState.isLoggedIn)
            await vm?.loadAnnonces()
        }
    }
}

// ── Panneau filtres avancés ───────────────────────────────

struct HomeFiltresView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: HomeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AppTextField(title: "Pays de départ",  placeholder: "FR", text: $vm.filtrePaysDepart)
                    AppTextField(title: "Ville de départ", placeholder: "Paris", text: $vm.filtreVilleDepart)
                    AppTextField(title: "Pays d'arrivée",  placeholder: "MA", text: $vm.filtrePaysArrivee)
                    AppTextField(title: "Ville d'arrivée", placeholder: "Casablanca", text: $vm.filtreVilleArrivee)

                    Toggle(isOn: $vm.filtreUrgence) {
                        Label("Annonces urgentes uniquement", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 15)).foregroundColor(.appTextPrimary)
                    }
                    .tint(.appPrimary)

                    Toggle(isOn: $vm.filtreFavoris) {
                        Label("Mes favoris uniquement", systemImage: "heart.fill")
                            .font(.system(size: 15)).foregroundColor(.appTextPrimary)
                    }
                    .tint(.appError)

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
                .padding(18)
            }
            .background(Color.appBackground)
            .navigationTitle("Filtres avancés")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") { dismiss() }.foregroundColor(.appPrimary)
                }
            }
        }
    }
}

// ── Filter Chip ───────────────────────────────────────────

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .appTextSecondary)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? Color.appPrimary : Color.appCanvas)
                .cornerRadius(99)
                .overlay(RoundedRectangle(cornerRadius: 99)
                    .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1))
        }
    }
}
