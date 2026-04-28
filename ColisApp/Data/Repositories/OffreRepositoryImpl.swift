import Foundation

class OffreRepositoryImpl: OffreRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }

    func getOffres(annonceId: String) async throws -> [Offre] {
        return try await apiClient.get(url: APIEndpoints.annonceOffres(id: annonceId))
    }

    func createOffre(annonceId: String, body: [String: Any]) async throws -> Offre {
        return try await apiClient.post(url: APIEndpoints.annonceOffres(id: annonceId), body: body)
    }

    func accepterOffre(offreId: String) async throws {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        let _: [String: String] = try await apiClient.put(
            url: APIEndpoints.offreAccepter(id: offreId),
            body: ["demandeurId": userId]
        )
    }

    func refuserOffre(offreId: String) async throws -> Offre {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.put(
            url: APIEndpoints.offreRefuser(id: offreId),
            body: ["demandeurId": userId]
        )
    }
}
