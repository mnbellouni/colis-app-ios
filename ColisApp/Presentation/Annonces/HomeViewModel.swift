import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {

    private let repository: any AnnonceRepository

    init(repository: any AnnonceRepository) {
        self.repository = repository
    }

    var annonces:      [Annonce] = []
    var isLoading      = false
    var error: String? = nil
    var selectedType: String? = nil

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
