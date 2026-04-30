import Observation
import Foundation

@Observable
final class AuthState {

    private let keychain = KeychainStorage()

    var isLoggedIn:  Bool    = false
    var userId:      String? = nil
    var userNom:     String? = nil
    var userPrenom:  String? = nil

    init() {
        refresh()
    }

    func refresh() {
        isLoggedIn = keychain.get(forKey: KeychainStorage.Keys.accessToken) != nil
        userId     = keychain.get(forKey: KeychainStorage.Keys.userId)
        userNom    = keychain.get(forKey: KeychainStorage.Keys.userNom)
        userPrenom = keychain.get(forKey: KeychainStorage.Keys.userPrenom)
    }

    func logout() {
        keychain.clear()
        isLoggedIn = false
        userId     = nil
        userNom    = nil
        userPrenom = nil
    }
}
