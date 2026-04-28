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

    // ── Annonces ──────────────────────────────────────────
    static var annonces:  String { "\(AppConfig.baseURL)/annonces" }
    static func annonce(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)" }
    static func annonceOffres(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)/offres" }
    static func annonceUploadUrl(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)/upload-url" }
    static func annoncePhotos(id: String) -> String { "\(AppConfig.baseURL)/annonces/\(id)/photos" }

    // ── Offres ────────────────────────────────────────────
    static func offreAccepter(id: String) -> String { "\(AppConfig.baseURL)/offres/\(id)/accepter" }
    static func offreRefuser(id: String) -> String { "\(AppConfig.baseURL)/offres/\(id)/refuser" }

    // ── Transactions ──────────────────────────────────────
    static func transaction(id: String) -> String { "\(AppConfig.baseURL)/transactions/\(id)" }
    static func transactionStatut(id: String) -> String { "\(AppConfig.baseURL)/transactions/\(id)/statut" }
    static func transactionConfirmer(id: String) -> String { "\(AppConfig.baseURL)/transactions/\(id)/confirmer" }
    static func transactionLitige(id: String) -> String { "\(AppConfig.baseURL)/transactions/\(id)/litige" }

    // ── Livraisons ────────────────────────────────────────
    static func livraison(id: String) -> String { "\(AppConfig.baseURL)/livraisons/\(id)" }
    static func livraisonStatut(id: String) -> String { "\(AppConfig.baseURL)/livraisons/\(id)/statut" }

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
    static var tags:        String { "\(AppConfig.baseURL)/tags" }
    static var zones:       String { "\(AppConfig.baseURL)/zones" }
    static var notifications: String { "\(AppConfig.baseURL)/notifications/token" }
}
