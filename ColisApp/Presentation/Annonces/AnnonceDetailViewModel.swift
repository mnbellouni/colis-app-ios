import Foundation
import Combine

@MainActor
final class AnnonceDetailViewModel: ObservableObject {

    private let annonceRepository:  any AnnonceRepository
    private let offreRepository:    any OffreRepository
    private let favorisRepository:  any FavorisRepository

    init(
        annonceRepository:  any AnnonceRepository,
        offreRepository:    any OffreRepository,
        favorisRepository:  any FavorisRepository
    ) {
        self.annonceRepository  = annonceRepository
        self.offreRepository    = offreRepository
        self.favorisRepository  = favorisRepository
    }

    @Published var annonce:      Annonce? = nil
    @Published var offres:       [Offre]  = []
    @Published var isFavori:     Bool     = false
    @Published var isLoading     = false
    @Published var offreEnvoyee  = false
    @Published var error: String? = nil

    func load(id: String, isLoggedIn: Bool = false) async {
        isLoading = true
        do {
            annonce = try await annonceRepository.getAnnonce(id: id)
        } catch {
            self.error = error.localizedDescription
        }
        if isLoggedIn {
            isFavori = (try? await favorisRepository.isFavori(annonceId: id)) ?? false
            offres   = (try? await offreRepository.getOffres(annonceId: id)) ?? []
        }
        isLoading = false
    }

    func toggleFavori(annonceId: String) async {
        let ancienEtat = isFavori
        isFavori = !isFavori
        do {
            if ancienEtat {
                try await favorisRepository.removeFavori(annonceId: annonceId)
            } else {
                try await favorisRepository.addFavori(annonceId: annonceId)
            }
        } catch {
            isFavori = ancienEtat
            self.error = error.localizedDescription
        }
    }

    func envoyerOffre(
        annonceId: String,
        trajetId: String,
        message: String,
        fraisService: Double,
        userId: String
    ) async {
        isLoading = true
        do {
            _ = try await offreRepository.createOffre(
                annonceId: annonceId,
                body: [
                    "voyageurId":   userId,
                    "trajetId":     trajetId,
                    "message":      message,
                    "fraisService": fraisService
                ]
            )
            offreEnvoyee = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
