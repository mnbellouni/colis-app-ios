import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    private let repository: any AnnonceRepository
    private let favorisRepository: any FavorisRepository

    init(repository: any AnnonceRepository, favorisRepository: any FavorisRepository) {
        self.repository        = repository
        self.favorisRepository = favorisRepository
    }

    @Published var annonces:       [Annonce] = []
    @Published var isLoading       = false
    @Published var error: String?  = nil
    @Published var selectedType: String? = nil

    // Filtres avancés
    @Published var showFiltres     = false
    @Published var filtrePaysDepart  = ""
    @Published var filtreVilleDepart = ""
    @Published var filtrePaysArrivee = ""
    @Published var filtreVilleArrivee = ""
    @Published var filtreUrgence   = false
    @Published var filtreFavoris   = false

    private var idsFavoris: Set<String> = []

    var filtresActifs: [(label: String, clear: () -> Void)] {
        var result: [(String, () -> Void)] = []
        if !filtrePaysDepart.isEmpty   { result.append(("Départ: \(filtrePaysDepart)", { self.filtrePaysDepart  = "" })) }
        if !filtreVilleDepart.isEmpty  { result.append(("Ville: \(filtreVilleDepart)", { self.filtreVilleDepart = "" })) }
        if !filtrePaysArrivee.isEmpty  { result.append(("Arrivée: \(filtrePaysArrivee)", { self.filtrePaysArrivee  = "" })) }
        if !filtreVilleArrivee.isEmpty { result.append(("Ville arr.: \(filtreVilleArrivee)", { self.filtreVilleArrivee = "" })) }
        if filtreUrgence               { result.append(("Urgent", { self.filtreUrgence = false })) }
        if filtreFavoris               { result.append(("Favoris", { self.filtreFavoris = false })) }
        return result
    }

    func loadAnnonces(type: String? = nil) async {
        isLoading = true
        error     = nil
        do {
            var params: [String: String] = [:]
            if let t = type ?? selectedType { params["type"] = t }
            if !filtrePaysDepart.isEmpty    { params["paysDepart"]   = filtrePaysDepart }
            if !filtreVilleDepart.isEmpty   { params["villeDepart"]  = filtreVilleDepart }
            if !filtrePaysArrivee.isEmpty   { params["paysArrivee"]  = filtrePaysArrivee }
            if !filtreVilleArrivee.isEmpty  { params["villeArrivee"] = filtreVilleArrivee }
            if filtreUrgence                { params["priorite"]     = "haute" }

            var items = try await repository.getAnnonces(params: params)

            if filtreFavoris {
                items = items.filter { idsFavoris.contains($0.id) }
            }

            annonces = items
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadFavorisIds(isLoggedIn: Bool) async {
        guard isLoggedIn else { return }
        let favs = (try? await favorisRepository.getMesFavoris()) ?? []
        idsFavoris = Set(favs.map { $0.id })
    }

    func appliquerFiltres() async {
        await loadAnnonces(type: selectedType)
    }

    func clearAllFilters() {
        filtrePaysDepart  = ""
        filtreVilleDepart = ""
        filtrePaysArrivee = ""
        filtreVilleArrivee = ""
        filtreUrgence     = false
        filtreFavoris     = false
    }
}
