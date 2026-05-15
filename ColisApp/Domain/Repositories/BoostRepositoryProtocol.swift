import Foundation

protocol BoostRepository {
    func getBoost(annonceId: String) async throws -> Boost
    func createBoost(annonceId: String) async throws -> Boost
}
