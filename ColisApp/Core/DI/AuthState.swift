import Observation

@Observable
final class AuthState {

    private let keychain = KeychainStorage()

    var isLoggedIn: Bool {
        keychain.get(forKey: KeychainStorage.Keys.accessToken) != nil
    }

    var userId: String? {
        keychain.get(forKey: KeychainStorage.Keys.userId)
    }

    var userNom: String? {
        keychain.get(forKey: KeychainStorage.Keys.userNom)
    }

    var userPrenom: String? {
        keychain.get(forKey: KeychainStorage.Keys.userPrenom)
    }

    func refresh() {
        _ = isLoggedIn
    }
}
