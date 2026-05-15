import Foundation

final class PaysRepositoryImpl: PaysRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getConfig() async throws -> RemoteConfig {
        return try await apiClient.get(url: APIEndpoints.config, requiresAuth: false)
    }
}
