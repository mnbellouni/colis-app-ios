import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    var isLoading  = false
    var error: String? = nil

    func login(email: String, password: String, authState: AuthState) async {
        guard !email.isEmpty, !password.isEmpty else {
            error = "Email et mot de passe requis"
            return
        }
        isLoading = true
        error     = nil
        do {
            _ = try await repository.login(email: email, password: password)
            authState.refresh()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
