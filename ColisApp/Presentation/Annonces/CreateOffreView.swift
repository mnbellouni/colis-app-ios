import SwiftUI

struct CreateOffreView: View {

    @EnvironmentObject private var authState: AuthState
    @Environment(\.factory)        private var factory
    @Environment(\.dismiss)        private var dismiss

    let annonceId: String
    @ObservedObject var vm: AnnonceDetailViewModel

    @State private var message      = ""
    @State private var prix         = ""
    @State private var trajets:     [Trajet] = []
    @State private var trajetId     = ""
    @State private var loadingTrajets = false

    var trajetSelectionne: Trajet? {
        trajets.first { $0.id == trajetId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Sélection trajet ──────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trajet associé *")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)

                        if loadingTrajets {
                            ProgressView().tint(.appPrimary)
                        } else if trajets.isEmpty {
                            VStack(spacing: 8) {
                                Text("Vous n'avez pas de trajet actif.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                                Text("Créez un trajet depuis votre profil pour pouvoir faire une offre.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.appTextTertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color.appWarningLight)
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(trajets) { trajet in
                                    TrajetSelectRow(
                                        trajet:   trajet,
                                        selected: trajetId == trajet.id
                                    ) {
                                        trajetId = trajet.id
                                    }
                                }
                            }
                        }
                    }

                    // ── Détails du trajet sélectionné ─────
                    if let t = trajetSelectionne {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Détails du trajet")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            HStack(spacing: 16) {
                                Label(String(t.dateDepart.prefix(10)), systemImage: "calendar")
                                Label(t.moyenTransport.capitalized, systemImage: "airplane")
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.appTextSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appPrimaryLight)
                        .cornerRadius(10)
                    }

                    // ── Prix ──────────────────────────────
                    AppTextField(
                        title:        "Prix proposé (€) *",
                        placeholder:  "15",
                        text:         $prix,
                        keyboardType: .decimalPad
                    )

                    // ── Message ───────────────────────────
                    AppTextField(
                        title:       "Message *",
                        placeholder: "Présentez votre offre à l'expéditeur…",
                        text:        $message
                    )

                    if let error = vm.error {
                        ErrorBanner(message: error)
                    }

                    AppButton(
                        title:     "Envoyer l'offre",
                        action: {
                            guard !trajetId.isEmpty else { return }
                            Task {
                                await vm.envoyerOffre(
                                    annonceId:    annonceId,
                                    trajetId:     trajetId,
                                    message:      message,
                                    fraisService: Double(prix) ?? 0,
                                    userId:       authState.userId ?? ""
                                )
                                dismiss()
                            }
                        },
                        isLoading: vm.isLoading
                    )
                    .disabled(trajetId.isEmpty || prix.isEmpty || message.isEmpty)
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Faire une offre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .task {
            loadingTrajets = true
            trajets = (try? await factory.makeTrajetRepository().getMesTrajets()) ?? []
            if let premier = trajets.first { trajetId = premier.id }
            loadingTrajets = false
        }
    }
}

// ── Ligne de sélection trajet ─────────────────────────────
struct TrajetSelectRow: View {
    let trajet:   Trajet
    let selected: Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .appPrimary : .appTextTertiary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(trajet.villeDepart) → \(trajet.villeArrivee)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    Text(String(trajet.dateDepart.prefix(10)))
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.appCard)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? Color.appPrimary : Color.appBorder, lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
