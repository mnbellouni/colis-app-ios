import Foundation
import Combine
import UIKit

@MainActor
final class CreateAnnonceViewModel: ObservableObject {

    private let repository:         any AnnonceRepository
    private let trajetRepository:   any TrajetRepository
    private let messageRepository:  any MessageRepository

    init(repository: any AnnonceRepository,
         trajetRepository: any TrajetRepository,
         messageRepository: any MessageRepository) {
        self.repository        = repository
        self.trajetRepository  = trajetRepository
        self.messageRepository = messageRepository
    }

    @Published var isLoading             = false
    @Published var isSuccess             = false
    @Published var annonce: Annonce?     = nil
    @Published var error: String?        = nil
    @Published var trajetsCompatibles:   [Trajet] = []
    @Published var trajetsSelectionnes:  Set<String> = []
    @Published var demandesEnvoyees      = false

    @Published var type              = "transport"
    @Published var titre             = ""
    @Published var description       = ""
    @Published var categories:       [String] = []
    @Published var tags:             [String] = []
    @Published var poids             = ""
    @Published var fragile           = false
    @Published var budget            = ""
    @Published var dateLimite        = Date()
    @Published var paysDepart        = "FR"
    @Published var villeDepart       = ""
    @Published var adresseDepart     = ""
    @Published var nomExpediteur     = ""
    @Published var prenomExpediteur  = ""
    @Published var paysArrivee       = "MA"
    @Published var villeArrivee      = ""
    @Published var adresseArrivee    = ""
    @Published var nomDestinataire   = ""
    @Published var prenomDestinataire = ""
    @Published var avecCodeSuivi     = false

    var dateLimiteISO: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.string(from: dateLimite)
    }

    func createAnnonce(userId: String) async {
        guard !titre.isEmpty, !categories.isEmpty,
              !villeDepart.isEmpty, !villeArrivee.isEmpty else {
            error = "Veuillez remplir tous les champs obligatoires"
            return
        }
        isLoading = true
        error     = nil
        do {
            annonce = try await repository.createAnnonce(body: [
                "type":               type,
                "demandeurId":        userId,
                "titre":              titre,
                "description":        description,
                "categories":         categories,
                "tags":               tags,
                "poids":              Double(poids) ?? 0,
                "fragile":            fragile,
                "budgetTransport":    Double(budget) ?? 0,
                "dateLimite":         dateLimiteISO,
                "paysDepart":         paysDepart,
                "villeDepart":        villeDepart,
                "adresseDepart":      adresseDepart,
                "nomExpediteur":      nomExpediteur,
                "prenomExpediteur":   prenomExpediteur,
                "paysArrivee":        paysArrivee,
                "villeArrivee":       villeArrivee,
                "adresseArrivee":     adresseArrivee,
                "nomDestinataire":    nomDestinataire,
                "prenomDestinataire": prenomDestinataire,
                "avecCodeSuivi":      avecCodeSuivi
            ])
            await loadTrajetsCompatibles()
            if trajetsCompatibles.isEmpty { isSuccess = true }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func loadTrajetsCompatibles() async {
        guard !villeDepart.isEmpty, !villeArrivee.isEmpty else { return }
        let items = (try? await trajetRepository.getTrajets(
            villeDepart: villeDepart,
            villeArrivee: villeArrivee,
            statut: "ouvert"
        )) ?? []
        trajetsCompatibles  = items
        trajetsSelectionnes = Set(items.map { $0.id })
    }

    func uploadPhotos(_ images: [UIImage], annonceId: String) async {
        for image in images.prefix(2) {
            guard let data = image.jpegData(compressionQuality: 0.85) else { continue }
            guard let urls = try? await repository.getUploadUrl(annonceId: annonceId, contentType: "image/jpeg"),
                  let uploadUrl = urls["uploadUrl"],
                  let photoUrl  = urls["photoUrl"] else { continue }
            var req = URLRequest(url: URL(string: uploadUrl)!)
            req.httpMethod = "PUT"
            req.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            _ = try? await URLSession.shared.upload(for: req, from: data)
            _ = try? await repository.addPhoto(annonceId: annonceId, photoUrl: photoUrl)
        }
    }

    func envoyerDemandes(annonceId: String, userId: String) async {
        isLoading = true
        let ids = trajetsSelectionnes
        for trajet in trajetsCompatibles where ids.contains(trajet.id) {
            let contenu = "Bonjour, j'ai publié une annonce de transport et je souhaite vous proposer mon colis. Seriez-vous disponible ?"
            _ = try? await messageRepository.sendMessage(
                destinataireId: trajet.voyageurId,
                contenu: contenu,
                annonceId: annonceId
            )
        }
        isLoading = false
        demandesEnvoyees = true
    }
}
