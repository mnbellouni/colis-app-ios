import Foundation
import Combine

@MainActor
final class TrajetViewModel: ObservableObject {

    private let repository: any TrajetRepository

    init(repository: any TrajetRepository) {
        self.repository = repository
    }

    @Published var trajets:    [Trajet] = []
    @Published var isLoading   = false
    @Published var isSuccess   = false
    @Published var error: String? = nil

    // Champs formulaire
    @Published var villeDepart    = ""
    @Published var villeArrivee   = ""
    @Published var paysDepart     = "FR"
    @Published var paysArrivee    = "MA"
    @Published var dateDepart     = Date()
    @Published var dateArrivee    = Date()
    @Published var moyenTransport = "avion"
    @Published var poidsDisponible = ""
    @Published var prixParKg       = ""

    let moyens = ["avion", "voiture", "train", "bus", "moto", "bateau"]

    func loadTrajets(villeDepart: String? = nil, villeArrivee: String? = nil) async {
        isLoading = true
        error     = nil
        do {
            trajets   = try await repository.getTrajets(
                villeDepart:  villeDepart,
                villeArrivee: villeArrivee
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func createTrajet(userId: String) async {
        guard !villeDepart.isEmpty, !villeArrivee.isEmpty,
              !poidsDisponible.isEmpty, !prixParKg.isEmpty else {
            error = "Veuillez remplir tous les champs"
            return
        }
        isLoading = true
        error     = nil
        let formatter = ISO8601DateFormatter()
        do {
            _ = try await repository.createTrajet(body: [
                "voyageurId":       userId,
                "villeDepart":      villeDepart,
                "villeArrivee":     villeArrivee,
                "paysDepart":       paysDepart,
                "paysArrivee":      paysArrivee,
                "dateDepart":       formatter.string(from: dateDepart),
                "dateArrivee":      formatter.string(from: dateArrivee),
                "moyenTransport":   moyenTransport,
                "poidsDisponible":  Double(poidsDisponible) ?? 0,
                "poidsRestant":     Double(poidsDisponible) ?? 0,
                "prixParKg":        Double(prixParKg) ?? 0,
                "categoriesAcceptees": ["vetements", "electronique", "documents", "autre"],
                "statut":           "ouvert"
            ])
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
