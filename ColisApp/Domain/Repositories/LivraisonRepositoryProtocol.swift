import Foundation

protocol LivraisonRepository {
    func getLivraison(id: String) async throws -> Livraison
    func updateStatut(id: String, statut: String) async throws -> Livraison
}
