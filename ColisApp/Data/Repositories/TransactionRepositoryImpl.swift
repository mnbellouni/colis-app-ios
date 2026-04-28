import Foundation

class TransactionRepositoryImpl: TransactionRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }

    func getTransaction(id: String) async throws -> Transaction {
        return try await apiClient.get(url: APIEndpoints.transaction(id: id))
    }

    func updateStatut(id: String, statut: String) async throws -> Transaction {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.put(
            url: APIEndpoints.transactionStatut(id: id),
            body: ["statut": statut, "userId": userId]
        )
    }

    func confirmer(id: String, code: String) async throws -> Transaction {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.transactionConfirmer(id: id),
            body: ["code": code, "userId": userId]
        )
    }

    func signalerLitige(id: String, raison: String) async throws -> Transaction {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.transactionLitige(id: id),
            body: ["raison": raison, "userId": userId]
        )
    }
}
