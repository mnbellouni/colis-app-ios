import Foundation
import Combine

@MainActor
final class TrajetViewModel: ObservableObject {

    private let repository: any TrajetRepository

    init(repository: any TrajetRepository) {
        self.repository = repository
    }

    @Published var trajets:        [Trajet] = []
    @Published var selectedTrajet: Trajet? = nil
    @Published var isLoading   = false
    @Published var isSuccess   = false
    @Published var error: String? = nil

    // ── Champs formulaire création ───────────────────────
    @Published var villeDepart    = ""
    @Published var villeArrivee   = ""
    @Published var paysDepart     = "FR"
    @Published var paysArrivee    = "MA"
    @Published var dateDepart     = Date()
    @Published var dateArrivee    = Date()
    @Published var moyenTransport = "avion"
    @Published var poidsDisponible = ""
    @Published var prixParKg       = ""
    @Published var etapes: [EtapeTrajetForm] = []
    @Published var categoriesSelectionnees: Set<String> = []

    // ── Recherche rapide ─────────────────────────────────
    @Published var searchDepart  = ""
    @Published var searchArrivee = ""

    // ── Filtres avancés ──────────────────────────────────
    @Published var showFilters       = false
    @Published var filtreVilleDepart = ""
    @Published var filtreVilleArrivee = ""
    @Published var filtreDate: Date? = nil
    @Published var filtreCategorie   = ""
    @Published var filtreMoyen       = ""
    @Published var filtrePoidsMin    = ""
    @Published var filtrePrixMax     = ""

    let moyens = ["avion", "voiture", "train", "bus", "moto", "bateau"]

    let toutesCategories = [
        "vetements", "electronique", "medicament", "documents",
        "alimentaire", "cosmetique", "cadeau", "autre"
    ]

    struct EtapeTrajetForm: Identifiable {
        let id = UUID()
        var ville: String = ""
        var pays: String = "FR"
    }

    var filtresActifs: [(label: String, clear: () -> Void)] {
        var result: [(String, () -> Void)] = []
        if !filtreVilleDepart.isEmpty {
            result.append(("Départ: \(filtreVilleDepart)", { self.filtreVilleDepart = "" }))
        }
        if !filtreVilleArrivee.isEmpty {
            result.append(("Arrivée: \(filtreVilleArrivee)", { self.filtreVilleArrivee = "" }))
        }
        if filtreDate != nil {
            let fmt = DateFormatter()
            fmt.dateStyle = .short
            result.append(("Date: \(fmt.string(from: filtreDate!))", { self.filtreDate = nil }))
        }
        if !filtreCategorie.isEmpty {
            result.append(("Cat: \(filtreCategorie.capitalized)", { self.filtreCategorie = "" }))
        }
        if !filtreMoyen.isEmpty {
            result.append(("Transport: \(filtreMoyen.capitalized)", { self.filtreMoyen = "" }))
        }
        if !filtrePoidsMin.isEmpty {
            result.append(("Poids min: \(filtrePoidsMin) kg", { self.filtrePoidsMin = "" }))
        }
        if !filtrePrixMax.isEmpty {
            result.append(("Prix max: \(filtrePrixMax) €/kg", { self.filtrePrixMax = "" }))
        }
        return result
    }

    var trajetsFiltres: [Trajet] {
        var result = trajets

        if !searchDepart.isEmpty {
            result = result.filter {
                $0.villeDepart.localizedCaseInsensitiveContains(searchDepart)
            }
        }
        if !searchArrivee.isEmpty {
            result = result.filter {
                $0.villeArrivee.localizedCaseInsensitiveContains(searchArrivee)
            }
        }
        if let date = filtreDate {
            let prefix = ISO8601DateFormatter().string(from: date).prefix(10)
            result = result.filter { $0.dateDepart.hasPrefix(String(prefix)) }
        }
        if !filtreCategorie.isEmpty {
            result = result.filter { $0.categoriesAcceptees.contains(filtreCategorie) }
        }
        if !filtreMoyen.isEmpty {
            result = result.filter { $0.moyenTransport == filtreMoyen }
        }
        if let poidsMin = Double(filtrePoidsMin), poidsMin > 0 {
            result = result.filter { $0.poidsRestant >= poidsMin }
        }
        if let prixMax = Double(filtrePrixMax), prixMax > 0 {
            result = result.filter { $0.prixParKg <= prixMax }
        }
        return result
    }

    func loadTrajet(id: String) async {
        isLoading = true
        error = nil
        do {
            selectedTrajet = try await repository.getTrajet(id: id)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadTrajets(villeDepart: String? = nil, villeArrivee: String? = nil) async {
        isLoading = true
        error     = nil
        do {
            trajets = try await repository.getTrajets(
                villeDepart:  villeDepart,
                villeArrivee: villeArrivee
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func appliquerFiltres() async {
        let vd = filtreVilleDepart.isEmpty ? nil : filtreVilleDepart
        let va = filtreVilleArrivee.isEmpty ? nil : filtreVilleArrivee
        await loadTrajets(villeDepart: vd, villeArrivee: va)
        showFilters = false
    }

    func clearAllFilters() {
        filtreVilleDepart = ""
        filtreVilleArrivee = ""
        filtreDate = nil
        filtreCategorie = ""
        filtreMoyen = ""
        filtrePoidsMin = ""
        filtrePrixMax = ""
        searchDepart = ""
        searchArrivee = ""
    }

    // ── Étapes intermédiaires ────────────────────────────
    func ajouterEtape() {
        etapes.append(EtapeTrajetForm())
    }

    func supprimerEtape(at index: Int) {
        guard etapes.indices.contains(index) else { return }
        etapes.remove(at: index)
    }

    func toggleCategorie(_ cat: String) {
        if categoriesSelectionnees.contains(cat) {
            categoriesSelectionnees.remove(cat)
        } else {
            categoriesSelectionnees.insert(cat)
        }
    }

    func createTrajet(userId: String) async {
        guard !villeDepart.isEmpty, !villeArrivee.isEmpty,
              !poidsDisponible.isEmpty, !prixParKg.isEmpty else {
            error = "Veuillez remplir tous les champs"
            return
        }
        isLoading = true
        error     = nil
        let formatter = ISO8601DateFormatter()

        let etapesData: [[String: String]] = etapes
            .filter { !$0.ville.isEmpty }
            .map { ["ville": $0.ville, "pays": $0.pays] }

        let cats: [String] = categoriesSelectionnees.isEmpty
            ? ["vetements", "electronique", "documents", "autre"]
            : Array(categoriesSelectionnees)

        do {
            _ = try await repository.createTrajet(body: [
                "voyageurId":          userId,
                "villeDepart":         villeDepart,
                "villeArrivee":        villeArrivee,
                "paysDepart":          paysDepart,
                "paysArrivee":         paysArrivee,
                "dateDepart":          formatter.string(from: dateDepart),
                "dateArrivee":         formatter.string(from: dateArrivee),
                "moyenTransport":      moyenTransport,
                "poidsDisponible":     Double(poidsDisponible) ?? 0,
                "poidsRestant":        Double(poidsDisponible) ?? 0,
                "prixParKg":           Double(prixParKg) ?? 0,
                "categoriesAcceptees": cats,
                "etapes":              etapesData,
                "statut":              "ouvert"
            ])
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
