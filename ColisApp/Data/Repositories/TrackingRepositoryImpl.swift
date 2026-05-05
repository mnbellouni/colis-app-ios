import Foundation

final class TrackingRepositoryImpl: TrackingRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }

    func getTracking(code: String) async throws -> ColisTracking {
        let clean = ColisCodeGenerator.normalize(code)
        return try await apiClient.get(
            url: APIEndpoints.trackingByCode(code: clean),
            requiresAuth: false
        )
    }

    func generateTracking(livraisonId: String) async throws -> ColisTracking {
        return try await apiClient.post(
            url: APIEndpoints.trackingForLivraison(livraisonId: livraisonId),
            body: ["code": ColisCodeGenerator.generate()]
        )
    }
}
