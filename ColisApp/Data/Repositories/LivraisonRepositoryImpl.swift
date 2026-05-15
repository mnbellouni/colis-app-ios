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

    func getMesLivraisons(role: String) async throws -> [Livraison] {
        return try await apiClient.get(url: APIEndpoints.mesLivraisons(role: role))
    }

    func getLivraisonsForTrajet(trajetId: String) async throws -> [Livraison] {
        return try await apiClient.get(url: APIEndpoints.livraisonsForTrajet(trajetId: trajetId))
    }

    func updateStatut(id: String, statut: String) async throws -> Livraison {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.put(
            url: APIEndpoints.livraisonStatut(id: id),
            body: ["statut": statut, "userId": userId]
        )
    }

    func genererCodeLivraison(id: String) async throws -> Livraison {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.livraisonGenererCodeLivraison(id: id),
            body: ["userId": userId]
        )
    }

    func validerCodeLivraison(id: String, code: String) async throws -> Livraison {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.livraisonValiderCodeLivraison(id: id),
            body: ["code": code, "userId": userId]
        )
    }

    func validerCodeSecret(id: String, code: String) async throws -> Livraison {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.livraisonValiderCodeSecret(id: id),
            body: ["code": code, "userId": userId]
        )
    }

    func signalerLitige(id: String, raison: String) async throws -> Livraison {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.livraisonLitige(id: id),
            body: ["raison": raison, "userId": userId]
        )
    }
}
