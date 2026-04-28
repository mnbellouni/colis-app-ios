import Foundation
import Security

final class KeychainStorage {

    init() {}

    func save(_ value: String, forKey key: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    func clear() {
        delete(forKey: Keys.accessToken)
        delete(forKey: Keys.refreshToken)
        delete(forKey: Keys.userId)
        delete(forKey: Keys.userEmail)
        delete(forKey: Keys.userNom)
        delete(forKey: Keys.userPrenom)
    }

    struct Keys {
        static let accessToken  = "access_token"
        static let refreshToken = "refresh_token"
        static let userId       = "user_id"
        static let userEmail    = "user_email"
        static let userNom      = "user_nom"
        static let userPrenom   = "user_prenom"
    }
}
