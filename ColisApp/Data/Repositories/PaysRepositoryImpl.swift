import Foundation

final class PaysRepositoryImpl: PaysRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getPays() async throws -> [Pays] {
        return try await apiClient.get(url: APIEndpoints.pays, requiresAuth: false)
    }
}
