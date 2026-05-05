import Foundation
import Observation

@Observable
@MainActor
final class LivraisonViewModel {

    private let livraisonRepository:   any LivraisonRepository
    private let transactionRepository: any TransactionRepository

    init(
        livraisonRepository:   any LivraisonRepository,
        transactionRepository: any TransactionRepository
    ) {
        self.livraisonRepository   = livraisonRepository
        self.transactionRepository = transactionRepository
    }

    var livraison:      Livraison? = nil
    var transaction:    Transaction? = nil
    var tracking:       ColisTracking? = nil
    var isLoading       = false
    var statutMisAJour  = false
    var error: String?  = nil

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
}
