import Foundation
import Combine

@MainActor
final class AnnonceDetailViewModel: ObservableObject {

    private let annonceRepository: any AnnonceRepository
    private let offreRepository:   any OffreRepository

    init(
        annonceRepository: any AnnonceRepository,
        offreRepository:   any OffreRepository
    ) {
        self.annonceRepository = annonceRepository
        self.offreRepository   = offreRepository
    }

    @Published var annonce:      Annonce? = nil
    @Published var offres:       [Offre] = []
    @Published var isLoading     = false
    @Published var offreEnvoyee  = false
    @Published var error: String? = nil

    func load(id: String) async {
        isLoading = true
        do {
            async let a = annonceRepository.getAnnonce(id: id)
            async let o = offreRepository.getOffres(annonceId: id)
            (annonce, offres) = try await (a, o)
        } catch {
            self.error = error.localizedDescription
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
