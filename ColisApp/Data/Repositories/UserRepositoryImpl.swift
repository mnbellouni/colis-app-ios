import Foundation

class UserRepositoryImpl: UserRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getUser(id: String) async throws -> User {
        return try await apiClient.get(url: APIEndpoints.user(id: id))
    }

    func updateUser(id: String, body: [String: String]) async throws -> User {
        return try await apiClient.put(url: APIEndpoints.user(id: id), body: body)
    }

    func getEvaluations(userId: String) async throws -> EvaluationResult {
        return try await apiClient.get(url: APIEndpoints.userEvaluations(id: userId))
    }
}
