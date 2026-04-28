import Foundation

protocol AnnonceRepository {
    func getAnnonces(type: String?, categorie: String?, paysSource: String?) async throws -> [Annonce]
    func getAnnonce(id: String) async throws -> Annonce
    func createAnnonce(body: [String: Any]) async throws -> Annonce
    func updateAnnonce(id: String, body: [String: Any]) async throws -> Annonce
    func deleteAnnonce(id: String) async throws
    func getUploadUrl(annonceId: String, contentType: String) async throws -> [String: String]
    func addPhoto(annonceId: String, photoUrl: String) async throws -> [String: [String]]
}
