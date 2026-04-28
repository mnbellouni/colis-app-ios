import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    @Published var isLoading  = false
    @Published var isSuccess  = false
    @Published var error: String? = nil

    func register(
        email: String,
        password: String,
        nom: String,
        prenom: String,
        telephone: String,
        authState: AuthState
    ) async {
        guard !email.isEmpty, !password.isEmpty,
              !nom.isEmpty, !prenom.isEmpty else {
            error = "Tous les champs sont requis"
            return
        }
        isLoading = true
        error     = nil
        do {
            _ = try await repository.register(
                email:     email,
                password:  password,
                nom:       nom,
                prenom:    prenom,
                telephone: telephone
            )
            isSuccess = true
            authState.refresh()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
