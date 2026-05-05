import SwiftUI

struct HomeView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    @State private var vm: HomeViewModel?
    @State private var selectedType: String? = nil
    @State private var showCreate = false
    @State private var showLogin = false

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

                        Button {
                            if authState.isLoggedIn {
                                showCreate = true
                            } else {
                                showLogin = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(LinearGradient.appPrimary)
                                .cornerRadius(13)
                        }
                    }

                    // ── Filtres ───────────────────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(types, id: \.0) { label, type in
                                FilterChip(
                                    label:      label,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                    Task { await vm?.loadAnnonces(type: type) }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color.appBackground)

                // ── Contenu ───────────────────────────────
                if vm?.isLoading == true {
                    Spacer()
                    ProgressView()
                        .tint(.appPrimary)
                    Spacer()
                } else if let error = vm?.error {
                    Spacer()
                    EmptyStateView(
                        icon:    "wifi.slash",
                        title:   "Erreur",
                        message: error
                    )
                    Spacer()
                } else if vm?.annonces.isEmpty == true {
                    Spacer()
                    EmptyStateView(
                        icon:    "shippingbox",
                        title:   "Aucune annonce",
                        message: "Soyez le premier à publier !"
                    )
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
                    .background(Color.appBackground)
                    .refreshable {
                        await vm?.loadAnnonces(type: selectedType)
                    }
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreate) {
                CreateAnnonceView()
            }
            .sheet(isPresented: $showLogin) {
                AuthNavigationView()
            }
        }
        .task {
            vm = factory.makeHomeViewModel()
            await vm?.loadAnnonces()
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
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appPrimary : Color.appCanvas)
                .cornerRadius(99)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
                )
        }
    }
}
