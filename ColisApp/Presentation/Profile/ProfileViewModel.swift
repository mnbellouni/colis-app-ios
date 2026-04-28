import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    private let userRepository: any UserRepository
    private let authRepository: any AuthRepository

    init(
        userRepository: any UserRepository,
        authRepository: any AuthRepository
    ) {
        self.userRepository = userRepository
        self.authRepository = authRepository
    }

    @Published var user:          User? = nil
    @Published var evaluations:   EvaluationResult? = nil
    @Published var isLoading      = false
    @Published var updateSuccess  = false
    @Published var error: String? = nil

    func loadProfile(userId: String) async {
        isLoading = true
        do {
            async let u = userRepository.getUser(id: userId)
            async let e = userRepository.getEvaluations(userId: userId)
            (user, evaluations) = try await (u, e)
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
