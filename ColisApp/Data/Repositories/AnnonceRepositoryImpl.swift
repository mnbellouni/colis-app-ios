import Foundation

class AnnonceRepositoryImpl: AnnonceRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getAnnonces(
        type: String? = nil,
        categorie: String? = nil,
        paysSource: String? = nil
    ) async throws -> [Annonce] {
        var url = APIEndpoints.annonces
        var params: [String] = []
        if let type      = type      { params.append("type=\(type)") }
        if let categorie = categorie { params.append("categorie=\(categorie)") }
        if let pays      = paysSource { params.append("paysSource=\(pays)") }
        if !params.isEmpty { url += "?" + params.joined(separator: "&") }
        return try await apiClient.get(url: url, requiresAuth: false)
    }

    func getAnnonce(id: String) async throws -> Annonce {
        return try await apiClient.get(url: APIEndpoints.annonce(id: id), requiresAuth: false)
    }

    func createAnnonce(body: [String: Any]) async throws -> Annonce {
        return try await apiClient.post(url: APIEndpoints.annonces, body: body)
    }

    func updateAnnonce(id: String, body: [String: Any]) async throws -> Annonce {
        return try await apiClient.put(url: APIEndpoints.annonce(id: id), body: body)
    }

    func deleteAnnonce(id: String) async throws {
        let _: [String: String] = try await apiClient.delete(url: APIEndpoints.annonce(id: id))
    }

    func getUploadUrl(annonceId: String, contentType: String) async throws -> [String: String] {
        let url = "\(APIEndpoints.annonceUploadUrl(id: annonceId))?contentType=\(contentType)"
        return try await apiClient.get(url: url)
    }

    func addPhoto(annonceId: String, photoUrl: String) async throws -> [String: [String]] {
        return try await apiClient.post(
            url: APIEndpoints.annoncePhotos(id: annonceId),
            body: ["photoUrl": photoUrl]
        )
    }
}
