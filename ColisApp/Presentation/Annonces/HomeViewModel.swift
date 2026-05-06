import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    private let repository: any AnnonceRepository

    init(repository: any AnnonceRepository) {
        self.repository = repository
    }

    @Published var annonces:      [Annonce] = []
    @Published var isLoading      = false
    @Published var error: String? = nil
    @Published var selectedType: String? = nil

    func loadAnnonces(type: String? = nil, categorie: String? = nil) async {
        isLoading = true
        error     = nil
        do {
            annonces = try await repository.getAnnonces(
                type:       type,
                categorie:  categorie,
                paysSource: nil
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func filterByType(_ type: String?) async {
        selectedType = type
        await loadAnnonces(type: type)
    }
}
