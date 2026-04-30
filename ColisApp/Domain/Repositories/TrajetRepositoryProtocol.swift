import Foundation

protocol TrajetRepository {
    func getTrajets(villeDepart: String?, villeArrivee: String?) async throws -> [Trajet]
    func getTrajet(id: String) async throws -> Trajet
    func createTrajet(body: [String: Any]) async throws -> Trajet
    func updateTrajet(id: String, body: [String: Any]) async throws -> Trajet
    func deleteTrajet(id: String) async throws
}
