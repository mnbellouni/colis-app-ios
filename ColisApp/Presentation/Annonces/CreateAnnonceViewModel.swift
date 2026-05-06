import Foundation
import Combine

@MainActor
final class CreateAnnonceViewModel: ObservableObject {

    private let repository: any AnnonceRepository

    init(repository: any AnnonceRepository) {
        self.repository = repository
    }

    @Published var isLoading     = false
    @Published var isSuccess     = false
    @Published var annonce: Annonce? = nil
    @Published var error: String? = nil

    @Published var type           = "transport"
    @Published var titre          = ""
    @Published var description    = ""
    @Published var categorie      = ""
    @Published var sousCategorie  = ""
    @Published var tags:          [String] = []
    @Published var poids          = ""
    @Published var fragile        = false
    @Published var budget         = ""
    @Published var paysDepart     = "FR"
    @Published var villeDepart    = ""
    @Published var adresseDepart  = ""
    @Published var paysArrivee    = "MA"
    @Published var villeArrivee   = ""
    @Published var adresseArrivee = ""
    @Published var avecCodeSuivi  = false

    func createAnnonce(userId: String) async {
        guard !titre.isEmpty, !categorie.isEmpty,
              !villeDepart.isEmpty, !villeArrivee.isEmpty else {
            error = "Veuillez remplir tous les champs obligatoires"
            return
        }
        isLoading = true
        error     = nil
        do {
            annonce = try await repository.createAnnonce(body: [
                "type":            type,
                "demandeurId":     userId,
                "titre":           titre,
                "description":     description,
                "categorie":       categorie,
                "sousCategorie":   sousCategorie,
                "tags":            tags,
                "poids":           Double(poids) ?? 0,
                "fragile":         fragile,
                "budgetTransport": Double(budget) ?? 0,
                "paysDepart":      paysDepart,
                "villeDepart":     villeDepart,
                "adresseDepart":   adresseDepart,
                "paysArrivee":     paysArrivee,
                "villeArrivee":    villeArrivee,
                "adresseArrivee":  adresseArrivee,
                "avecCodeSuivi":   avecCodeSuivi
            ])
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
