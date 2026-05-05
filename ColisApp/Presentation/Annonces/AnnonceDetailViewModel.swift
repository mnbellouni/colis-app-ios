import Foundation
import Observation

@Observable
@MainActor
final class AnnonceDetailViewModel {

    private let annonceRepository: any AnnonceRepository
    private let offreRepository:   any OffreRepository

    init(
        annonceRepository: any AnnonceRepository,
        offreRepository:   any OffreRepository
    ) {
        self.annonceRepository = annonceRepository
        self.offreRepository   = offreRepository
    }

    var annonce:      Annonce? = nil
    var offres:       [Offre] = []
    var isLoading     = false
    var offreEnvoyee  = false
    var error: String? = nil

    func load(id: String, isLoggedIn: Bool = false) async {
        isLoading = true
        do {
            annonce = try await annonceRepository.getAnnonce(id: id)
        } catch {
            self.error = error.localizedDescription
        }
        if isLoggedIn {
            do {
                offres = try await offreRepository.getOffres(annonceId: id)
            } catch {
                offres = []
            }
        }
        isLoading = false
    }

    func envoyerOffre(
        annonceId: String,
        message: String,
        fraisService: Double,
        villeDepart: String,
        villeArrivee: String,
        dateDepart: String,
        dateArrivee: String,
        moyenTransport: String,
        userId: String
    ) async {
        isLoading = true
        do {
            _ = try await offreRepository.createOffre(
                annonceId: annonceId,
                body: [
                    "voyageurId":     userId,
                    "message":        message,
                    "fraisService":   fraisService,
                    "villeDepart":    villeDepart,
                    "villeArrivee":   villeArrivee,
                    "dateDepart":     dateDepart,
                    "dateArrivee":    dateArrivee,
                    "moyenTransport": moyenTransport
                ]
            )
            offreEnvoyee = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
