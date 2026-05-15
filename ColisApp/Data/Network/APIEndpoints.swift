import Foundation

enum APIEndpoints {

    // ── Auth ──────────────────────────────────────────────
    static var register:  String { "\(AppConfig.baseURL)/auth/register" }
    static var login:     String { "\(AppConfig.baseURL)/auth/login" }
    static var logout:    String { "\(AppConfig.baseURL)/auth/logout" }
    static var refresh:   String { "\(AppConfig.baseURL)/auth/refresh" }

    // ── Users ─────────────────────────────────────────────
    static var users:     String { "\(AppConfig.baseURL)/users" }
    static func user(id: String) -> String { "\(AppConfig.baseURL)/users/\(id)" }
    static func userEvaluations(id: String) -> String { "\(AppConfig.baseURL)/users/\(id)/evaluations" }
    static func userCertification(id: String) -> String { "\(AppConfig.baseURL)/users/\(id)/certification" }

    // ── Annonces ──────────────────────────────────────────
    static var annonces:  String { "\(AppConfig.baseURL)/annonces" }
    static func annonce(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)" }
    static func annonceOffres(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)/offres" }
    static func annonceUploadUrl(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)/upload-url" }
    static func annoncePhotos(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)/photos" }

    // ── Offres ────────────────────────────────────────────
    static var offresLimit: String { "\(AppConfig.baseURL)/offres/limit" }
    static func offreAccepter(id: String) -> String { "\(AppConfig.baseURL)/offres/\(id)/accepter" }
    static func offreRefuser(id: String) -> String { "\(AppConfig.baseURL)/offres/\(id)/refuser" }

    // ── Livraisons ────────────────────────────────────────
    static func livraison(id: String) -> String { "\(AppConfig.baseURL)/livraisons/\(id)" }
    static func livraisonStatut(id: String) -> String { "\(AppConfig.baseURL)/livraisons/\(id)/statut" }
    static func mesLivraisons(role: String) -> String { "\(AppConfig.baseURL)/livraisons/me?role=\(role)" }
    static func livraisonsForTrajet(trajetId: String) -> String { "\(AppConfig.baseURL)/trajets/\(trajetId)/livraisons" }
    static func livraisonGenererCodeLivraison(id: String) -> String { "\(AppConfig.baseURL)/livraisons/\(id)/code-livraison/generer" }
    static func livraisonValiderCodeLivraison(id: String) -> String { "\(AppConfig.baseURL)/livraisons/\(id)/code-livraison/valider" }
    static func livraisonValiderCodeSecret(id: String) -> String    { "\(AppConfig.baseURL)/livraisons/\(id)/code-secret/valider" }
    static func livraisonLitige(id: String) -> String              { "\(AppConfig.baseURL)/livraisons/\(id)/litige" }

    // ── Messages ──────────────────────────────────────────
    static var messages:  String { "\(AppConfig.baseURL)/messages" }
    static func conversation(id: String) -> String { "\(AppConfig.baseURL)/messages/\(id)" }

    // ── Evaluations ───────────────────────────────────────
    static var evaluations: String { "\(AppConfig.baseURL)/evaluations" }

    // ── Boosts ────────────────────────────────────────────
    static var boosts:      String { "\(AppConfig.baseURL)/boosts" }
    static var boostTypes:  String { "\(AppConfig.baseURL)/boosts/types" }
    static func boost(id: String) -> String { "\(AppConfig.baseURL)/boosts/\(id)" }

    // ── Misc ──────────────────────────────────────────────
    static var config:      String { "\(AppConfig.baseURL)/config" }
    static var notifications: String { "\(AppConfig.baseURL)/notifications/token" }
    
    // ── Tracking ──────────────────────────────────────────────
    static func trackingByCode(code: String) -> String { "\(AppConfig.baseURL)/tracking/\(code)" }
    static func trackingForLivraison(livraisonId: String) -> String { "\(AppConfig.baseURL)/livraisons/\(livraisonId)/tracking" }

    // ── Trajets ───────────────────────────────────────────────
    static var trajets:      String { "\(AppConfig.baseURL)/trajets" }
    static var trajetsLimit: String { "\(AppConfig.baseURL)/trajets/limit" }
    static func trajet(id: String) -> String { "\(AppConfig.baseURL)/trajets/\(id)" }

    // ── Favoris ───────────────────────────────────────────────
    static var favoris: String { "\(AppConfig.baseURL)/favoris" }
    static func favori(annonceId: String) -> String { "\(AppConfig.baseURL)/favoris/\(annonceId)" }
}
