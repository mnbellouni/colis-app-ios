import Foundation
import Combine

@MainActor
final class CreateAnnonceViewModel: ObservableObject {

    private let repository:      any AnnonceRepository
    private let trajetRepository: any TrajetRepository

    init(repository: any AnnonceRepository, trajetRepository: any TrajetRepository) {
        self.repository       = repository
        self.trajetRepository = trajetRepository
    }

    @Published var isLoading             = false
    @Published var isSuccess             = false
    @Published var annonce: Annonce?     = nil
    @Published var error: String?        = nil
    @Published var trajetsCompatibles:   [Trajet] = []
    @Published var trajetsSelectionnes:  Set<String> = []
    @Published var demandesEnvoyees      = false

    @Published var type              = "transport"
    @Published var titre             = ""
    @Published var description       = ""
    @Published var categories:       [String] = []
    @Published var tags:             [String] = []
    @Published var poids             = ""
    @Published var fragile           = false
    @Published var budget            = ""
    @Published var dateLimite        = Date()
    @Published var paysDepart        = "FR"
    @Published var villeDepart       = ""
    @Published var adresseDepart     = ""
    @Published var nomExpediteur     = ""
    @Published var prenomExpediteur  = ""
    @Published var paysArrivee       = "MA"
    @Published var villeArrivee      = ""
    @Published var adresseArrivee    = ""
    @Published var nomDestinataire   = ""
    @Published var prenomDestinataire = ""
    @Published var avecCodeSuivi     = false

    var dateLimiteISO: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.string(from: dateLimite)
    }

    func createAnnonce(userId: String) async {
        guard !titre.isEmpty, !categories.isEmpty,
              !villeDepart.isEmpty, !villeArrivee.isEmpty else {
            error = "Veuillez remplir tous les champs obligatoires"
            return
        }
        isLoading = true
        error     = nil
        do {
            annonce = try await repository.createAnnonce(body: [
                "type":               type,
                "demandeurId":        userId,
                "titre":              titre,
                "description":        description,
                "categories":         categories,
                "tags":               tags,
                "poids":              Double(poids) ?? 0,
                "fragile":            fragile,
                "budgetTransport":    Double(budget) ?? 0,
                "dateLimite":         dateLimiteISO,
                "paysDepart":         paysDepart,
                "villeDepart":        villeDepart,
                "adresseDepart":      adresseDepart,
                "nomExpediteur":      nomExpediteur,
                "prenomExpediteur":   prenomExpediteur,
                "paysArrivee":        paysArrivee,
                "villeArrivee":       villeArrivee,
                "adresseArrivee":     adresseArrivee,
                "nomDestinataire":    nomDestinataire,
                "prenomDestinataire": prenomDestinataire,
                "avecCodeSuivi":      avecCodeSuivi
            ])
            await loadTrajetsCompatibles()
            if trajetsCompatibles.isEmpty { isSuccess = true }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func loadTrajetsCompatibles() async {
        guard !villeDepart.isEmpty, !villeArrivee.isEmpty else { return }
        let items = (try? await trajetRepository.getTrajets(
            villeDepart: villeDepart,
            villeArrivee: villeArrivee,
            statut: "ouvert"
        )) ?? []
        trajetsCompatibles  = items
        trajetsSelectionnes = Set(items.map { $0.id })
    }

    func envoyerDemandes(annonceId: String, userId: String) async {
        let ids = trajetsSelectionnes
        for trajet in trajetsCompatibles where ids.contains(trajet.id) {
            _ = try? await repository.getAnnonces(params: [:])
        }
        demandesEnvoyees = true
    }
}
