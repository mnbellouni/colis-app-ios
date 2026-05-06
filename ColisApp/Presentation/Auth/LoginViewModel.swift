import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    private let repository: any AuthRepository
    private let userRepository: any UserRepository

    init(repository: any AuthRepository, userRepository: any UserRepository) {
        self.repository = repository
        self.userRepository = userRepository
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
            let authResponse = try await repository.login(email: email, password: password)
            authState.refresh()
            
            guard !authResponse.userId.isEmpty else { return }
            
            do {
                let user = try await userRepository.getUser(id: authResponse.userId)
                let keychain = KeychainStorage()
                keychain.save(user.certificationStatus, forKey: "certificationStatus")
                authState.refresh()
            } catch {
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
