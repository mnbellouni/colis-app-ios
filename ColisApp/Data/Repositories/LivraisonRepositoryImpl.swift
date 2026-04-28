import Foundation

class LivraisonRepositoryImpl: LivraisonRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage
    
    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }

    func getLivraison(id: String) async throws -> Livraison {
        return try await apiClient.get(url: APIEndpoints.livraison(id: id))
    }

    func updateStatut(id: String, statut: String) async throws -> Livraison {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.put(
            url: APIEndpoints.livraisonStatut(id: id),
            body: ["statut": statut, "userId": userId]
        )
    }
}
