import Foundation
import Combine

@MainActor
final class AnnonceDetailViewModel: ObservableObject {

    private let annonceRepository:  any AnnonceRepository
    private let offreRepository:    any OffreRepository
    private let favorisRepository:  any FavorisRepository
    private let userRepository:     any UserRepository
    private let trajetRepository:   any TrajetRepository

    init(
        annonceRepository:  any AnnonceRepository,
        offreRepository:    any OffreRepository,
        favorisRepository:  any FavorisRepository,
        userRepository:     any UserRepository,
        trajetRepository:   any TrajetRepository
    ) {
        self.annonceRepository  = annonceRepository
        self.offreRepository    = offreRepository
        self.favorisRepository  = favorisRepository
        self.userRepository     = userRepository
        self.trajetRepository   = trajetRepository
    }

    @Published var annonce:              Annonce?         = nil
    @Published var annonceur:            User?            = nil
    @Published var evaluationsAnnonceur: EvaluationResult? = nil
    @Published var offres:               [Offre]          = []
    @Published var isFavori:             Bool             = false
    @Published var userHasTrajets:       Bool             = false
    @Published var isLoading             = false
    @Published var offreEnvoyee          = false
    @Published var statutChange          = false
    @Published var error: String?        = nil

    func load(id: String, isLoggedIn: Bool = false) async {
        isLoading = true
        do {
            annonce = try await annonceRepository.getAnnonce(id: id)
            if let demandeurId = annonce?.demandeurId {
                annonceur            = try? await userRepository.getUser(id: demandeurId)
                evaluationsAnnonceur = try? await userRepository.getEvaluations(userId: demandeurId)
            }
        } catch {
            self.error = error.localizedDescription
        }
        if isLoggedIn {
            isFavori       = (try? await favorisRepository.isFavori(annonceId: id)) ?? false
            offres         = (try? await offreRepository.getOffres(annonceId: id)) ?? []
            let trajets    = (try? await trajetRepository.getMesTrajets()) ?? []
            userHasTrajets = !trajets.isEmpty
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

    func fermerAnnonce() async {
        guard let id = annonce?.id else { return }
        isLoading = true
        do {
            annonce = try await annonceRepository.changeStatut(id: id, statut: "fermee", conversationId: nil)
            statutChange = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func marquerPourvue(conversationId: String?) async {
        guard let id = annonce?.id else { return }
        isLoading = true
        do {
            annonce = try await annonceRepository.changeStatut(id: id, statut: "pourvue", conversationId: conversationId)
            statutChange = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
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
