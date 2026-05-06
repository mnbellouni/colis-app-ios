import Foundation
import Combine

@MainActor
final class LivraisonViewModel: ObservableObject {

    private let livraisonRepository:   any LivraisonRepository
    private let transactionRepository: any TransactionRepository

    init(
        livraisonRepository:   any LivraisonRepository,
        transactionRepository: any TransactionRepository
    ) {
        self.livraisonRepository   = livraisonRepository
        self.transactionRepository = transactionRepository
    }

    @Published var livraison:      Livraison? = nil
    @Published var transaction:    Transaction? = nil
    @Published var tracking:       ColisTracking? = nil
    @Published var isLoading       = false
    @Published var statutMisAJour  = false
    @Published var error: String?  = nil

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
