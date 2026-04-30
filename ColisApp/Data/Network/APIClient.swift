import Foundation

final class APIClient {

    private let session:  URLSession
    private let keychainStorage: KeychainStorage

    // Callback appelé si le token est invalide → déconnexion
    var onUnauthorized: (() -> Void)?

    init(keychainStorage: KeychainStorage) {
        self.keychainStorage = keychainStorage
        self.session  = URLSession.shared
    }

    // ── Requête principale ────────────────────────────────
    func request<T: Decodable>(
        url:          String,
        method:       String = "GET",
        body:         [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {

        guard let requestURL = URL(string: url) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ── Injection du token ────────────────────────────
        if requiresAuth {
            guard let token = keychainStorage.get(forKey: KeychainStorage.Keys.accessToken) else {
                onUnauthorized?()
                throw APIError.unauthorized
            }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        if AppConfig.isDebug {
            print("→ \(method) \(url)")
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            if AppConfig.isDebug {
                print("← \(httpResponse.statusCode) \(url)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    if AppConfig.isDebug {
                        print("❌ Decoding error: \(error)")
                        print("❌ Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    }
                    throw APIError.decodingError(error)
                }

            case 401:
                // ── Token expiré → tenter refresh ─────────
                let refreshed = await tryRefreshToken()
                if refreshed {
                    // Relancer la requête avec le nouveau token
                    return try await request(
                        url:          url,
                        method:       method,
                        body:         body,
                        requiresAuth: requiresAuth
                    )
                } else {
                    // Refresh échoué → déconnexion
                    onUnauthorized?()
                    throw APIError.unauthorized
                }

            default:
                let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message   = errorBody?["erreur"] as? String ?? "Erreur serveur"
                throw APIError.serverError(httpResponse.statusCode, message)
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // ── Refresh Token ─────────────────────────────────────
    private func tryRefreshToken() async -> Bool {
        guard let refreshToken = keychainStorage.get(
            forKey: KeychainStorage.Keys.refreshToken
        ) else { return false }

        guard let url = URL(string: APIEndpoints.refresh) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: ["refreshToken": refreshToken]
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                return false
            }

            let result = try JSONDecoder().decode(TokenResponse.self, from: data)
            keychainStorage.save(result.accessToken, forKey: KeychainStorage.Keys.accessToken)
            if let idToken = result.idToken {
                keychainStorage.save(idToken, forKey: KeychainStorage.Keys.idToken)
            }
            return true
        } catch {
            return false
        }
    }

    // ── Méthodes raccourcis ───────────────────────────────
    func get<T: Decodable>(url: String, requiresAuth: Bool = true) async throws -> T {
        try await request(url: url, method: "GET", requiresAuth: requiresAuth)
    }

    func post<T: Decodable>(url: String, body: [String: Any], requiresAuth: Bool = true) async throws -> T {
        try await request(url: url, method: "POST", body: body, requiresAuth: requiresAuth)
    }

    func put<T: Decodable>(url: String, body: [String: Any], requiresAuth: Bool = true) async throws -> T {
        try await request(url: url, method: "PUT", body: body, requiresAuth: requiresAuth)
    }

    func delete<T: Decodable>(url: String, requiresAuth: Bool = true) async throws -> T {
        try await request(url: url, method: "DELETE", requiresAuth: requiresAuth)
    }
}

// ── Modèle de réponse refresh ─────────────────────────────
struct TokenResponse: Decodable {
    let accessToken: String
    let idToken: String?
    let expiresIn: Int
}
