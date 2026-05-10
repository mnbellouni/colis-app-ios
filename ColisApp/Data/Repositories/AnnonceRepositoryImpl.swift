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
        var p: [String: String] = [:]
        if let type      = type      { p["type"]       = type }
        if let categorie = categorie { p["categorie"]  = categorie }
        if let pays      = paysSource { p["paysSource"] = pays }
        return try await getAnnonces(params: p)
    }

    func getAnnonces(params: [String: String]) async throws -> [Annonce] {
        let page: PagedResult<Annonce> = try await getAnnoncesPage(params: params)
        return page.items
    }

    func getAnnoncesPage(params: [String: String]) async throws -> PagedResult<Annonce> {
        var url = APIEndpoints.annonces
        if !params.isEmpty {
            let qs = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
                .joined(separator: "&")
            url += "?" + qs
        }
        return try await apiClient.get(url: url, requiresAuth: false)
    }

    func getMesAnnonces(demandeurId: String) async throws -> [Annonce] {
        let url = "\(APIEndpoints.annonces)?demandeurId=\(demandeurId)"
        return try await apiClient.get(url: url)
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

    func toggleActif(id: String) async throws -> Annonce {
        return try await apiClient.put(url: "\(APIEndpoints.annonce(id: id))/actif", body: [:])
    }

    func changeStatut(id: String, statut: String, conversationId: String?) async throws -> Annonce {
        var body: [String: Any] = ["statut": statut]
        if let cid = conversationId { body["conversationId"] = cid }
        return try await apiClient.put(url: "\(APIEndpoints.annonce(id: id))/statut", body: body)
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
