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

    @Published var pays:           [Pays]    = []
    @Published var annonces:       [Annonce] = []
    @Published var isLoading       = true
    @Published var isLoadingMore   = false
    @Published var error: String?  = nil
    @Published var selectedType: String? = nil

    // Filtres avancés
    @Published var showFiltres           = false
    @Published var filtreTags            = Set<String>()
    @Published var filtrePaysDepart      = Set<String>()
    @Published var filtrePaysArrivee     = Set<String>()
    @Published var filtreVilleDepart     = ""
    @Published var filtreVilleArrivee    = ""
    @Published var filtreUrgence         = false
    @Published var filtreFavoris         = false

    private var nextToken: String?   = nil
    @Published var idsFavoris: Set<String> = []

    var hasMore: Bool { nextToken != nil }

    var filtresActifs: [(label: String, clear: () -> Void)] {
        var result: [(String, () -> Void)] = []
        for tag in filtreTags.sorted() {
            let captured = tag
            result.append(("Tag: \(tag)", { self.filtreTags.remove(captured) }))
        }
        if !filtrePaysDepart.isEmpty   {
            let label = filtrePaysDepart.count == 1
                ? "Départ: \(filtrePaysDepart.first!)"
                : "Départ: \(filtrePaysDepart.count)"
            result.append((label, { self.filtrePaysDepart = [] }))
        }
        if !filtreVilleDepart.isEmpty  { result.append(("Ville: \(filtreVilleDepart)",       { self.filtreVilleDepart  = "" })) }
        if !filtrePaysArrivee.isEmpty  {
            let label = filtrePaysArrivee.count == 1
                ? "Arrivée: \(filtrePaysArrivee.first!)"
                : "Arrivée: \(filtrePaysArrivee.count)"
            result.append((label, { self.filtrePaysArrivee = [] }))
        }
        if !filtreVilleArrivee.isEmpty { result.append(("Ville arr.: \(filtreVilleArrivee)", { self.filtreVilleArrivee = "" })) }
        if filtreUrgence               { result.append(("Urgent",  { self.filtreUrgence  = false })) }
        if filtreFavoris               { result.append(("Favoris", { self.filtreFavoris  = false })) }
        return result
    }

    func loadAnnonces(type: String? = nil) async {
        isLoading = true
        error     = nil
        nextToken = nil
        do {
            let params  = buildParams(type: type ?? selectedType)
            let page    = try await repository.getAnnoncesPage(params: params)
            var items   = page.items
            items = applyClientFilters(items)
            annonces  = items
            nextToken = page.nextToken
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore, let token = nextToken else { return }
        isLoadingMore = true
        do {
            var params  = buildParams(type: selectedType)
            params["nextToken"] = token
            let page    = try await repository.getAnnoncesPage(params: params)
            var items   = page.items
            items = applyClientFilters(items)
            annonces += items
            nextToken = page.nextToken
        } catch {}
        isLoadingMore = false
    }

    func loadPays(from config: RemoteConfig) {
        pays = config.pays.isEmpty ? Pays.defauts : config.pays
    }

    func loadFavorisIds(isLoggedIn: Bool) async {
        guard isLoggedIn else { return }
        let favs = (try? await favorisRepository.getMesFavoris()) ?? []
        idsFavoris = Set(favs.map { $0.id })
    }

    func toggleFavori(annonceId: String) async {
        let estFavori = idsFavoris.contains(annonceId)
        if estFavori {
            idsFavoris.remove(annonceId)
            try? await favorisRepository.removeFavori(annonceId: annonceId)
        } else {
            idsFavoris.insert(annonceId)
            try? await favorisRepository.addFavori(annonceId: annonceId)
        }
    }

    func appliquerFiltres() async {
        await loadAnnonces(type: selectedType)
    }

    func clearAllFilters() {
        filtreTags         = []
        filtrePaysDepart   = []
        filtrePaysArrivee  = []
        filtreVilleDepart  = ""
        filtreVilleArrivee = ""
        filtreUrgence      = false
        filtreFavoris      = false
    }

    private func buildParams(type: String?) -> [String: String] {
        var p: [String: String] = ["limit": "20"]
        if let t = type                     { p["type"]        = t }
        if !filtrePaysDepart.isEmpty        { p["paysDepart"]  = filtrePaysDepart.sorted().joined(separator: ",") }
        if !filtreVilleDepart.isEmpty       { p["villeDepart"] = filtreVilleDepart }
        if !filtrePaysArrivee.isEmpty       { p["paysArrivee"] = filtrePaysArrivee.sorted().joined(separator: ",") }
        if !filtreVilleArrivee.isEmpty      { p["villeArrivee"] = filtreVilleArrivee }
        // Tags : fusion des tags sélectionnés manuellement + tag "urgent" si toggle activé
        var tagsActifs = filtreTags
        if filtreUrgence { tagsActifs.insert("urgent") }
        if !tagsActifs.isEmpty              { p["tag"] = tagsActifs.sorted().joined(separator: ",") }
        return p
    }

    // Filtrage client-side pour favoris
    private func applyClientFilters(_ items: [Annonce]) -> [Annonce] {
        guard filtreFavoris else { return items }
        return items.filter { idsFavoris.contains($0.id) }
    }
}
