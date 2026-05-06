import SwiftUI

struct CreateTrajetView: View {

    @EnvironmentObject private var authState: AuthState
    @Environment(\.dismiss)        private var dismiss

    @ObservedObject var vm: TrajetViewModel

    let pays = ["FR", "MA", "DZ", "TN", "ES", "IT", "DE", "BE", "GB"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Ville départ ─────────────────────
                    HStack(spacing: 12) {
                        AppTextField(
                            title:       "Ville départ",
                            placeholder: "Paris",
                            text:        $vm.villeDepart
                        )
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pays")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Picker("", selection: $vm.paysDepart) {
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

                    // ── Étapes intermédiaires ────────────
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Étapes intermédiaires")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Spacer()
                            Button {
                                vm.ajouterEtape()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Ajouter")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.appPrimary)
                            }
                        }

                        if !vm.etapes.isEmpty {
                            ForEach(Array(vm.etapes.enumerated()), id: \.element.id) { index, etape in
                                HStack(spacing: 8) {
                                    VStack(spacing: 0) {
                                        Rectangle()
                                            .fill(Color.appPrimary.opacity(0.3))
                                            .frame(width: 2, height: 12)
                                        Circle()
                                            .fill(Color.appPrimary.opacity(0.5))
                                            .frame(width: 8, height: 8)
                                        Rectangle()
                                            .fill(Color.appPrimary.opacity(0.3))
                                            .frame(width: 2, height: 12)
                                    }

                                    AppTextField(
                                        title:       "Escale \(index + 1)",
                                        placeholder: "Lyon",
                                        text:        Binding(
                                            get: { vm.etapes[safe: index]?.ville ?? "" },
                                            set: { vm.etapes[safe: index]?.ville = $0 }
                                        )
                                    )

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Pays")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.appTextSecondary)
                                        Picker("", selection: Binding(
                                            get: { vm.etapes[safe: index]?.pays ?? "FR" },
                                            set: { vm.etapes[safe: index]?.pays = $0 }
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
                                    .frame(width: 90)

                                    Button {
                                        vm.supprimerEtape(at: index)
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.appError.opacity(0.7))
                                    }
                                    .padding(.top, 20)
                                }
                            }
                        } else {
                            Text("Aucune escale — trajet direct")
                                .font(.system(size: 13))
                                .foregroundColor(.appTextTertiary)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(14)
                    .background(Color.appCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appBorder))

                    // ── Ville arrivée ────────────────────
                    HStack(spacing: 12) {
                        AppTextField(
                            title:       "Ville arrivée",
                            placeholder: "Casablanca",
                            text:        $vm.villeArrivee
                        )
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pays")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Picker("", selection: $vm.paysArrivee) {
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

                    // ── Dates ─────────────────────────────
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date de départ")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            DatePicker("", selection: $vm.dateDepart, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date d'arrivée")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            DatePicker("", selection: $vm.dateArrivee, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }
                    }

                    // ── Moyen de transport ────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Moyen de transport")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        Picker("", selection: $vm.moyenTransport) {
                            ForEach(vm.moyens, id: \.self) { moyen in
                                Text(moyen.capitalized).tag(moyen)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // ── Poids et prix ─────────────────────
                    HStack(spacing: 12) {
                        AppTextField(
                            title:        "Poids disponible (kg)",
                            placeholder:  "10",
                            text:         $vm.poidsDisponible,
                            keyboardType: .decimalPad
                        )
                        AppTextField(
                            title:        "Prix/kg (€)",
                            placeholder:  "2.50",
                            text:         $vm.prixParKg,
                            keyboardType: .decimalPad
                        )
                    }

                    // ── Catégories acceptées ──────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Catégories de colis acceptées")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        FlowLayout(spacing: 8) {
                            ForEach(vm.toutesCategories, id: \.self) { cat in
                                FilterChip(
                                    label:      cat.capitalized,
                                    isSelected: vm.categoriesSelectionnees.contains(cat)
                                ) {
                                    vm.toggleCategorie(cat)
                                }
                            }
                        }
                        Text("Laissez vide pour accepter toutes les catégories")
                            .font(.system(size: 11))
                            .foregroundColor(.appTextTertiary)
                    }

                    if let error = vm.error {
                        ErrorBanner(message: error)
                    }

                    AppButton(
                        title:     "Publier mon trajet",
                        action:    { Task { await vm.createTrajet(userId: authState.userId ?? "") } },
                        isLoading: vm.isLoading
                    )
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Proposer un trajet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.appPrimary)
                }
            }
            .onChange(of: vm.isSuccess) { success in
                if success { dismiss() }
            }
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        get { indices.contains(index) ? self[index] : nil }
        set {
            guard indices.contains(index), let value = newValue else { return }
            self[index] = value
        }
    }
}
