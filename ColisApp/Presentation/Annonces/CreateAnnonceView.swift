import SwiftUI

struct CreateAnnonceView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss)      private var dismiss

    @State private var vm: CreateAnnonceViewModel?

    let categories = ["vetements", "electronique", "medicament",
                      "documents", "alimentaire", "cosmetique", "cadeau", "autre"]
    let pays = ["FR", "MA", "DZ", "TN", "ES", "IT", "DE", "BE", "GB"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Type ──────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type d'annonce")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        Picker("Type", selection: Binding(
                            get:  { vm?.type ?? "transport" },
                            set:  { vm?.type = $0 }
                        )) {
                            Text("Transport").tag("transport")
                            Text("Achat + Transport").tag("achat_transport")
                        }
                        .pickerStyle(.segmented)
                    }

                    AppTextField(
                        title:       "Titre",
                        placeholder: "Ex: Colis vêtements famille",
                        text:        Binding(
                            get: { vm?.titre ?? "" },
                            set: { vm?.titre = $0 }
                        )
                    )

                    AppTextField(
                        title:       "Description",
                        placeholder: "Décrivez votre colis...",
                        text:        Binding(
                            get: { vm?.description ?? "" },
                            set: { vm?.description = $0 }
                        )
                    )

                    // ── Catégorie ─────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Catégorie")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    FilterChip(
                                        label:      cat.capitalized,
                                        isSelected: vm?.categorie == cat
                                    ) {
                                        vm?.categorie = cat
                                    }
                                }
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        AppTextField(
                            title:        "Poids (kg)",
                            placeholder:  "2.5",
                            text:         Binding(
                                get: { vm?.poids ?? "" },
                                set: { vm?.poids = $0 }
                            ),
                            keyboardType: .decimalPad
                        )
                        AppTextField(
                            title:        "Budget (€)",
                            placeholder:  "15",
                            text:         Binding(
                                get: { vm?.budget ?? "" },
                                set: { vm?.budget = $0 }
                            ),
                            keyboardType: .decimalPad
                        )
                    }

                    // ── Pays départ ───────────────────────
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pays départ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Picker("", selection: Binding(
                                get:  { vm?.paysDepart ?? "FR" },
                                set:  { vm?.paysDepart = $0 }
                            )) {
                                ForEach(pays, id: \.self) { p in
                                    Text("\(p.flagEmoji) \(p)").tag(p)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Color.appBackground)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBorder))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pays arrivée")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Picker("", selection: Binding(
                                get:  { vm?.paysArrivee ?? "MA" },
                                set:  { vm?.paysArrivee = $0 }
                            )) {
                                ForEach(pays, id: \.self) { p in
                                    Text("\(p.flagEmoji) \(p)").tag(p)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Color.appBackground)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBorder))
                        }
                    }

                    AppTextField(
                        title:       "Ville départ",
                        placeholder: "Paris",
                        text:        Binding(
                            get: { vm?.villeDepart ?? "" },
                            set: { vm?.villeDepart = $0 }
                        )
                    )

                    AppTextField(
                        title:       "Adresse départ",
                        placeholder: "10 rue de la Paix",
                        text:        Binding(
                            get: { vm?.adresseDepart ?? "" },
                            set: { vm?.adresseDepart = $0 }
                        )
                    )

                    AppTextField(
                        title:       "Ville arrivée",
                        placeholder: "Casablanca",
                        text:        Binding(
                            get: { vm?.villeArrivee ?? "" },
                            set: { vm?.villeArrivee = $0 }
                        )
                    )

                    AppTextField(
                        title:       "Adresse arrivée",
                        placeholder: "5 rue Hassan II",
                        text:        Binding(
                            get: { vm?.adresseArrivee ?? "" },
                            set: { vm?.adresseArrivee = $0 }
                        )
                    )

                    // ── Fragile ───────────────────────────
                    Toggle(isOn: Binding(
                        get: { vm?.fragile ?? false },
                        set: { vm?.fragile = $0 }
                    )) {
                        Label("Colis fragile", systemImage: "exclamationmark.triangle")
                            .font(.system(size: 15))
                            .foregroundColor(.appTextPrimary)
                    }
                    .tint(.appPrimary)

                    if let error = vm?.error {
                        ErrorBanner(message: error)
                    }

                    AppButton(
                        title:     "Publier l'annonce",
                        action:    { Task { await vm?.createAnnonce(userId: authState.userId ?? "") } },
                        isLoading: vm?.isLoading ?? false
                    )
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Nouvelle annonce")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.appPrimary)
                }
            }
            .onChange(of: vm?.isSuccess ?? false) { _, success in
                if success { dismiss() }
            }
        }
        .task {
            vm = factory.makeCreateAnnonceViewModel()
        }
    }
}
