import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(email: String, password: String, nom: String, prenom: String, telephone: String) async throws -> [String: String]
    func logout() async throws
    func isLoggedIn() -> Bool
    func getAccessToken() -> String?
    func getUserId() -> String?
    func clearSession()
}
