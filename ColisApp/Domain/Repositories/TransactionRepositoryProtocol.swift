import Foundation

protocol TransactionRepository {
    func getTransaction(id: String) async throws -> Transaction
    func updateStatut(id: String, statut: String) async throws -> Transaction
    func confirmer(id: String, code: String) async throws -> Transaction
    func signalerLitige(id: String, raison: String) async throws -> Transaction
}
