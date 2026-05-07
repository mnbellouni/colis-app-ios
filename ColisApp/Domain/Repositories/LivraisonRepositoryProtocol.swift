import Foundation

protocol LivraisonRepository {
    func getLivraison(id: String) async throws -> Livraison
    func getMesLivraisons(role: String) async throws -> [Livraison]
    func getLivraisonsForTrajet(trajetId: String) async throws -> [Livraison]
    func updateStatut(id: String, statut: String) async throws -> Livraison
}
