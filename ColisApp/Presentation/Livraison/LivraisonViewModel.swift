import Foundation
import Combine

@MainActor
final class LivraisonViewModel: ObservableObject {

    private let livraisonRepository: any LivraisonRepository

    init(livraisonRepository: any LivraisonRepository) {
        self.livraisonRepository = livraisonRepository
    }

    @Published var livraison:     Livraison? = nil
    @Published var tracking:      ColisTracking? = nil
    @Published var isLoading      = false
    @Published var statutMisAJour = false
    @Published var error: String? = nil

    func load(livraisonId: String) async {
        isLoading = true
        do {
            livraison = try await livraisonRepository.getLivraison(id: livraisonId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func updateStatut(livraisonId: String, statut: String) async {
        isLoading = true
        do {
            livraison      = try await livraisonRepository.updateStatut(id: livraisonId, statut: statut)
            statutMisAJour = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func genererCodeLivraison(livraisonId: String) async {
        isLoading = true
        do {
            livraison = try await livraisonRepository.genererCodeLivraison(id: livraisonId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func validerCodeLivraison(livraisonId: String, code: String) async {
        isLoading = true
        do {
            livraison = try await livraisonRepository.validerCodeLivraison(id: livraisonId, code: code)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func validerCodeSecret(livraisonId: String, code: String) async {
        isLoading = true
        do {
            livraison = try await livraisonRepository.validerCodeSecret(id: livraisonId, code: code)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signalerLitige(livraisonId: String, raison: String) async {
        isLoading = true
        do {
            livraison = try await livraisonRepository.signalerLitige(id: livraisonId, raison: raison)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
