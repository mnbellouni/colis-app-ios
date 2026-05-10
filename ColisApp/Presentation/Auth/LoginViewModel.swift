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
        isLoading = true
        error     = nil
        do {
            let authResponse = try await repository.login(email: email, password: password)
            authState.refresh()

            guard !authResponse.userId.isEmpty else {
                isLoading = false
                return
            }

            do {
                let user = try await userRepository.getUser(id: authResponse.userId)
                let keychain = KeychainStorage()
                keychain.save(user.certificationStatus,         forKey: KeychainStorage.Keys.certificationStatus)
                keychain.save(user.typeAbonnement ?? "standard", forKey: KeychainStorage.Keys.typeAbonnement)
                authState.refresh()
            } catch {}
        } catch {
            self.error = mapError(error)
        }
        isLoading = false
    }

    private func mapError(_ error: Error) -> String {
        if case APIError.serverError(let code, _) = error {
            switch code {
            case 401:        return "Email ou mot de passe incorrect"
            case 403:        return "Votre compte a été désactivé. Contactez le support."
            case 500, 502, 503: return "Une erreur est survenue. Veuillez réessayer."
            default:         break
            }
        }
        return "Une erreur est survenue. Veuillez réessayer."
    }
}
