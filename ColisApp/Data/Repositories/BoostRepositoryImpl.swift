import Foundation

class BoostRepositoryImpl: BoostRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }

    func getTypes() async throws -> [String: BoostType] {
        return try await apiClient.get(url: APIEndpoints.boostTypes, requiresAuth: false)
    }

    func getBoost(annonceId: String) async throws -> Boost {
        return try await apiClient.get(url: APIEndpoints.boost(id: annonceId))
    }

    func createBoost(annonceId: String, type: String) async throws -> Boost {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.boosts,
            body: [
                "annonceId": annonceId,
                "userId":    userId,
                "type":      type
            ]
        )
    }
}
