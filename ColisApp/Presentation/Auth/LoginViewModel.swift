import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    @Published var isLoading  = false
    @Published var error: String? = nil

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
