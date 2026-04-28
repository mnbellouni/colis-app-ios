import Foundation

protocol BoostRepository {
    func getTypes() async throws -> [String: BoostType]
    func getBoost(annonceId: String) async throws -> Boost
    func createBoost(annonceId: String, type: String) async throws -> Boost
}
