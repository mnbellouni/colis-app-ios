import Foundation

protocol AnnonceRepository {
    func getAnnonces(type: String?, categorie: String?, paysSource: String?) async throws -> [Annonce]
    func getAnnonces(params: [String: String]) async throws -> [Annonce]
    func getAnnoncesPage(params: [String: String]) async throws -> PagedResult<Annonce>
    func getMesAnnonces(demandeurId: String) async throws -> [Annonce]
    func getAnnonce(id: String) async throws -> Annonce
    func createAnnonce(body: [String: Any]) async throws -> Annonce
    func updateAnnonce(id: String, body: [String: Any]) async throws -> Annonce
    func deleteAnnonce(id: String) async throws
    func toggleActif(id: String) async throws -> Annonce
    func changeStatut(id: String, statut: String, conversationId: String?) async throws -> Annonce
    func getUploadUrl(annonceId: String, contentType: String) async throws -> UploadUrlResponse
    func addPhoto(annonceId: String, photoUrl: String) async throws -> [String: [String]]
}
