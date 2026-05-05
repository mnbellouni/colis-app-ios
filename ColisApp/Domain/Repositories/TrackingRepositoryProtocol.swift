import Foundation

protocol TrackingRepository {
    func getTracking(code: String) async throws -> ColisTracking
    func generateTracking(livraisonId: String) async throws -> ColisTracking
}
