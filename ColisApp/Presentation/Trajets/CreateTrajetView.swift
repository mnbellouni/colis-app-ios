import SwiftUI

struct CreateTrajetView: View {

    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss)      private var dismiss

    let vm: TrajetViewModel?

    let pays = ["FR", "MA", "DZ", "TN", "ES", "IT", "DE", "BE", "GB"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Villes ────────────────────────────
                    HStack(spacing: 12) {
                        AppTextField(
                            title:       "Ville départ",
                            placeholder: "Paris",
                            text:        Binding(
                                get: { vm?.villeDepart ?? "" },
                                set: { vm?.villeDepart = $0 }
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
                    }

                    // ── Pays ──────────────────────────────
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

                    // ── Dates ─────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date de départ")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { vm?.dateDepart ?? Date() },
                                set: { vm?.dateDepart = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date d'arrivée")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { vm?.dateArrivee ?? Date() },
                                set: { vm?.dateArrivee = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                    }

                    // ── Moyen de transport ────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Moyen de transport")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        Picker("", selection: Binding(
                            get:  { vm?.moyenTransport ?? "avion" },
                            set:  { vm?.moyenTransport = $0 }
                        )) {
                            ForEach(vm?.moyens ?? [], id: \.self) { moyen in
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
                            text:         Binding(
                                get: { vm?.poidsDisponible ?? "" },
                                set: { vm?.poidsDisponible = $0 }
                            ),
                            keyboardType: .decimalPad
                        )
                        AppTextField(
                            title:        "Prix/kg (€)",
                            placeholder:  "2.50",
                            text:         Binding(
                                get: { vm?.prixParKg ?? "" },
                                set: { vm?.prixParKg = $0 }
                            ),
                            keyboardType: .decimalPad
                        )
                    }

                    if let error = vm?.error {
                        ErrorBanner(message: error)
                    }

                    AppButton(
                        title:     "Publier mon trajet",
                        action:    {
                            Task {
                                await vm?.createTrajet(userId: authState.userId ?? "")
                            }
                        },
                        isLoading: vm?.isLoading ?? false
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
            .onChange(of: vm?.isSuccess ?? false) { _, success in
                if success { dismiss() }
            }
        }
    }
}
