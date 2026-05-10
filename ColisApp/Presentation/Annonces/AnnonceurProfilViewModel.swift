import Foundation
import Combine

@MainActor
final class AnnonceurProfilViewModel: ObservableObject {

    private let userRepository:    any UserRepository
    private let annonceRepository: any AnnonceRepository

    init(userRepository: any UserRepository, annonceRepository: any AnnonceRepository) {
        self.userRepository    = userRepository
        self.annonceRepository = annonceRepository
    }

    @Published var user:        User?            = nil
    @Published var evaluations: EvaluationResult? = nil
    @Published var nbAnnonces:  Int              = 0
    @Published var isLoading    = false
    @Published var error: String? = nil

    func load(userId: String) async {
        isLoading = true
        error = nil
        do {
            user = try await userRepository.getUser(id: userId)
        } catch {
            self.error = error.localizedDescription
        }
        evaluations = try? await userRepository.getEvaluations(userId: userId)
        nbAnnonces  = (try? await annonceRepository.getMesAnnonces(demandeurId: userId))?.count ?? 0
        isLoading   = false
    }
}
