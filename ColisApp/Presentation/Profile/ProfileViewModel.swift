import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    private let userRepository: any UserRepository
    private let authRepository: any AuthRepository

    init(
        userRepository: any UserRepository,
        authRepository: any AuthRepository
    ) {
        self.userRepository = userRepository
        self.authRepository = authRepository
    }

    var user:          User? = nil
    var evaluations:   EvaluationResult? = nil
    var isLoading      = false
    var updateSuccess  = false
    var error: String? = nil

    func loadProfile(userId: String) async {
        isLoading = true
        do {
            user = try await userRepository.getUser(id: userId)
            evaluations = try await userRepository.getEvaluations(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func updateProfile(
        userId: String,
        nom: String,
        prenom: String,
        telephone: String,
        bio: String
    ) async {
        isLoading = true
        do {
            user = try await userRepository.updateUser(
                id: userId,
                body: ["nom": nom, "prenom": prenom, "telephone": telephone, "bio": bio]
            )
            updateSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func logout(authState: AuthState) async {
        do {
            try await authRepository.logout()
        } catch {
            authRepository.clearSession()
        }
        authState.refresh()
    }
}
