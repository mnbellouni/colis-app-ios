import Foundation
import Combine

@MainActor
final class AuthState: ObservableObject {
    

    private let keychain = KeychainStorage()

    @Published var isLoggedIn:  Bool    = false
    @Published var userId:      String? = nil
    @Published var userNom:     String? = nil
    @Published var userPrenom:  String? = nil
    @Published var certificationStatus: String? = nil

    init() {
        refresh()
    }

    func refresh() {
        isLoggedIn = keychain.get(forKey: KeychainStorage.Keys.accessToken) != nil
        userId     = keychain.get(forKey: KeychainStorage.Keys.userId)
        userNom    = keychain.get(forKey: KeychainStorage.Keys.userNom)
        userPrenom = keychain.get(forKey: KeychainStorage.Keys.userPrenom)
        certificationStatus = keychain.get(forKey: "certificationStatus")
    }

    func refreshTokenIfNeeded(apiClient: APIClient) async {
        guard keychain.get(forKey: KeychainStorage.Keys.refreshToken) != nil else { return }

        let shouldRefresh: Bool
        if let expiryString = keychain.get(forKey: KeychainStorage.Keys.tokenExpiry),
           let expiryInterval = Double(expiryString) {
            let expiryDate = Date(timeIntervalSince1970: expiryInterval)
            shouldRefresh = Date().addingTimeInterval(10 * 60) >= expiryDate
        } else {
            shouldRefresh = keychain.get(forKey: KeychainStorage.Keys.accessToken) != nil
        }

        guard shouldRefresh else { return }

        guard let refreshToken = keychain.get(forKey: KeychainStorage.Keys.refreshToken),
              let url = URL(string: APIEndpoints.refresh) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: ["refreshToken": refreshToken]
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                logout()
                return
            }
            let result = try JSONDecoder().decode(TokenResponse.self, from: data)
            keychain.save(result.accessToken, forKey: KeychainStorage.Keys.accessToken)
            if let idToken = result.idToken {
                keychain.save(idToken, forKey: KeychainStorage.Keys.idToken)
            }
            let expiry = Date().addingTimeInterval(Double(result.expiresIn))
            keychain.save(String(expiry.timeIntervalSince1970), forKey: KeychainStorage.Keys.tokenExpiry)
            refresh()
        } catch {
            logout()
        }
    }

    func logout() {
        keychain.clear()
        isLoggedIn = false
        userId     = nil
        userNom    = nil
        userPrenom = nil
        certificationStatus = nil
    }
}
