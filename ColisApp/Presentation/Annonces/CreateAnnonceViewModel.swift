import Foundation
import Observation

@Observable
@MainActor
final class CreateAnnonceViewModel {

    private let repository: any AnnonceRepository

    init(repository: any AnnonceRepository) {
        self.repository = repository
    }

    var isLoading     = false
    var isSuccess     = false
    var annonce: Annonce? = nil
    var error: String? = nil

    var type           = "transport"
    var titre          = ""
    var description    = ""
    var categorie      = ""
    var sousCategorie  = ""
    var tags:          [String] = []
    var poids          = ""
    var fragile        = false
    var budget         = ""
    var paysDepart     = "FR"
    var villeDepart    = ""
    var adresseDepart  = ""
    var paysArrivee    = "MA"
    var villeArrivee   = ""
    var adresseArrivee = ""

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
                "adresseArrivee":  adresseArrivee
            ])
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
