import Foundation

class AuthRepositoryImpl: AuthRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage  = keychainStorage
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let response: AuthResponse = try await apiClient.post(
            url: APIEndpoints.login,
            body: ["email": email, "password": password],
            requiresAuth: false
        )
        // Sauvegarder les tokens
        keychainStorage.save(response.accessToken,  forKey: KeychainStorage.Keys.accessToken)
        keychainStorage.save(response.refreshToken, forKey: KeychainStorage.Keys.refreshToken)
        keychainStorage.save(response.userId,       forKey: KeychainStorage.Keys.userId)
        keychainStorage.save(response.email,        forKey: KeychainStorage.Keys.userEmail)
        keychainStorage.save(response.nom,          forKey: KeychainStorage.Keys.userNom)
        keychainStorage.save(response.prenom,       forKey: KeychainStorage.Keys.userPrenom)
        return response
    }

    func register(
        email: String,
        password: String,
        nom: String,
        prenom: String,
        telephone: String
    ) async throws -> [String: String] {
        return try await apiClient.post(
            url: APIEndpoints.register,
            body: [
                "email":     email,
                "password":  password,
                "nom":       nom,
                "prenom":    prenom,
                "telephone": telephone
            ],
            requiresAuth: false
        )
    }

    func logout() async throws {
        let token = keychainStorage.get(forKey: KeychainStorage.Keys.accessToken) ?? ""
        let _: [String: String] = try await apiClient.post(
            url: APIEndpoints.logout,
            body: ["accessToken": token]
        )
        keychainStorage.clear()
    }

    func isLoggedIn() -> Bool {
        return keychainStorage.get(forKey: KeychainStorage.Keys.accessToken) != nil
    }

    func getAccessToken() -> String? {
        return keychainStorage.get(forKey: KeychainStorage.Keys.accessToken)
    }

    func getUserId() -> String? {
        return keychainStorage.get(forKey: KeychainStorage.Keys.userId)
    }

    func clearSession() {
        keychainStorage.clear()
    }
}
