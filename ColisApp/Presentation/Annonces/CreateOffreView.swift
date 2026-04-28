import SwiftUI

struct CreateOffreView: View {

    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss)      private var dismiss

    let annonceId: String
    let vm: AnnonceDetailViewModel?

    @State private var message        = ""
    @State private var fraisService   = ""
    @State private var villeDepart    = ""
    @State private var villeArrivee   = ""
    @State private var dateDepart     = Date()
    @State private var dateArrivee    = Date()
    @State private var moyenTransport = "avion"

    let moyens = ["avion", "voiture", "train", "bus", "moto"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    AppTextField(
                        title:       "Message",
                        placeholder: "Décrivez votre offre...",
                        text:        $message
                    )

                    AppTextField(
                        title:        "Frais de service (€)",
                        placeholder:  "15",
                        text:         $fraisService,
                        keyboardType: .decimalPad
                    )

                    HStack(spacing: 12) {
                        AppTextField(title: "Ville départ",  placeholder: "Paris",      text: $villeDepart)
                        AppTextField(title: "Ville arrivée", placeholder: "Casablanca", text: $villeArrivee)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Moyen de transport")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        Picker("Transport", selection: $moyenTransport) {
                            ForEach(moyens, id: \.self) { moyen in
                                Text(moyen.capitalized).tag(moyen)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date de départ")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        DatePicker("", selection: $dateDepart, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date d'arrivée")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        DatePicker("", selection: $dateArrivee, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }

                    if let error = vm?.error {
                        ErrorBanner(message: error)
                    }

                    AppButton(
                        title:     "Envoyer l'offre",
                        action: {
                            Task {
                                let formatter = ISO8601DateFormatter()
                                await vm?.envoyerOffre(
                                    annonceId:      annonceId,
                                    message:        message,
                                    fraisService:   Double(fraisService) ?? 0,
                                    villeDepart:    villeDepart,
                                    villeArrivee:   villeArrivee,
                                    dateDepart:     formatter.string(from: dateDepart),
                                    dateArrivee:    formatter.string(from: dateArrivee),
                                    moyenTransport: moyenTransport,
                                    userId:         authState.userId ?? ""
                                )
                                dismiss()
                            }
                        },
                        isLoading: vm?.isLoading ?? false
                    )
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
    }
}
