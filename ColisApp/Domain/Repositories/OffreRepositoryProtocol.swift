import Foundation

protocol OffreRepository {
    func getOffres(annonceId: String) async throws -> [Offre]
    func createOffre(annonceId: String, body: [String: Any]) async throws -> Offre
    func accepterOffre(offreId: String) async throws
    func refuserOffre(offreId: String) async throws -> Offre
}
