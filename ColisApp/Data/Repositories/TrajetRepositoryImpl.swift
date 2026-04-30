import Foundation

final class TrajetRepositoryImpl: TrajetRepository {

    private let apiClient: APIClient
    private let keychainStorage:  KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage  = keychainStorage
    }

    func getTrajets(villeDepart: String? = nil, villeArrivee: String? = nil) async throws -> [Trajet] {
        var url = APIEndpoints.trajets
        var params: [String] = []
        if let vd = villeDepart  { params.append("villeDepart=\(vd)") }
        if let va = villeArrivee { params.append("villeArrivee=\(va)") }
        if !params.isEmpty { url += "?" + params.joined(separator: "&") }
        return try await apiClient.get(url: url, requiresAuth: false)
    }

    func getTrajet(id: String) async throws -> Trajet {
        return try await apiClient.get(url: APIEndpoints.trajet(id: id), requiresAuth: false)
    }

    func createTrajet(body: [String: Any]) async throws -> Trajet {
        return try await apiClient.post(url: APIEndpoints.trajets, body: body)
    }

    func updateTrajet(id: String, body: [String: Any]) async throws -> Trajet {
        return try await apiClient.put(url: APIEndpoints.trajet(id: id), body: body)
    }

    func deleteTrajet(id: String) async throws {
        let _: [String: String] = try await apiClient.delete(url: APIEndpoints.trajet(id: id))
    }
}
