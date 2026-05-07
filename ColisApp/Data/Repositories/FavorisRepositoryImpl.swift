import Foundation

class FavorisRepositoryImpl: FavorisRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getMesFavoris() async throws -> [Annonce] {
        return try await apiClient.get(url: APIEndpoints.favoris)
    }

    func addFavori(annonceId: String) async throws {
        let _: [String: String] = try await apiClient.post(
            url: APIEndpoints.favoris,
            body: ["annonceId": annonceId]
        )
    }

    func removeFavori(annonceId: String) async throws {
        let _: [String: String] = try await apiClient.delete(
            url: APIEndpoints.favori(annonceId: annonceId)
        )
    }

    func isFavori(annonceId: String) async throws -> Bool {
        struct R: Decodable { let isFavori: Bool }
        let r: R = try await apiClient.get(url: APIEndpoints.favori(annonceId: annonceId))
        return r.isFavori
    }
}
