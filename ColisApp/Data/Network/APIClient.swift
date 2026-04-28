import Foundation

final class APIClient {

    private let session  = URLSession.shared
    private let keychainStorage: KeychainStorage

    init(keychainStorage: KeychainStorage) {
        self.keychainStorage = keychainStorage
    }

    func request<T: Decodable>(
        url: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {

        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            if let token = keychainStorage.get(forKey: KeychainStorage.Keys.accessToken) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        if AppConfig.isDebug {
            print("→ \(method) \(url)")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        if AppConfig.isDebug {
            print("← \(httpResponse.statusCode)")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        default:
            let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message   = errorBody?["erreur"] as? String ?? "Erreur serveur"
            throw APIError.serverError(httpResponse.statusCode, message)
        }
    }

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
