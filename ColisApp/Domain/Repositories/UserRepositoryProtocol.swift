import Foundation

protocol UserRepository {
    func getUser(id: String) async throws -> User
    func updateUser(id: String, body: [String: String]) async throws -> User
    func getEvaluations(userId: String) async throws -> EvaluationResult
}
