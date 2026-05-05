//
//  User.swift
//  ColisApp
//
//  Created by Nadjib Bellouni on 26/04/2026.
//


import Foundation

// ── User ──────────────────────────────────────────────────
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let nom: String
    let prenom: String
    let telephone: String
    let photo: String
    let bio: String
    let typeCompte: String
    let noteVoyageur: Double
    let noteExpediteur: Double
    let nbLivraisons: Double
    let verified: Bool
    let actif: Bool
    let createdAt: String

    var nomComplet: String { "\(prenom) \(nom)" }
}

struct AuthResponse: Codable {
    let accessToken: String
    let idToken: String
    let refreshToken: String
    let expiresIn: Int
    let userId: String
    let nom: String
    let prenom: String
    let email: String
}

// ── Annonce ───────────────────────────────────────────────
struct Annonce: Codable, Identifiable {
    let id: String
    let type: String
    let demandeurId: String
    let titre: String
    let description: String
    let photos: [String]
    let categorie: String
    let sousCategorie: String
    let tags: [String]
    let priorite: String
    let poids: Double
    let fragile: Bool
    let budgetTransport: Double
    let devise: String
    let dateLimite: String
    let statut: String
    let boost: Bool
    let nbOffres: Double
    let paysDepart: String
    let villeDepart: String
    let adresseDepart: String
    let paysArrivee: String?
    let villeArrivee: String?
    let adresseArrivee: String?
    let paysSource: String?
    let achat: Achat?
    let createdAt: String
    let updatedAt: String

    var isTransport: Bool { type == "transport" }
    var isAchat: Bool { type == "achat_transport" }
    var isUrgent: Bool { tags.contains("urgent") || tags.contains("tres_urgent") }
    var isBoosted: Bool { boost }
}

struct Achat: Codable {
    let nomProduit: String
    let urlProduit: String
    let prixObjet: Double
    let deviseObjet: String
    let magasin: String
    let instructions: String
}

// ── Offre ─────────────────────────────────────────────────
struct Offre: Codable, Identifiable {
    let id: String
    let annonceId: String
    let voyageurId: String
    let message: String
    let fraisService: Double
    let villeDepart: String
    let villeArrivee: String
    let dateDepart: String
    let dateArrivee: String
    let moyenTransport: String
    let statut: String
    let createdAt: String
}

// ── Transaction ───────────────────────────────────────────
struct Transaction: Codable, Identifiable {
    let id: String
    let annonceId: String
    let offreId: String
    let demandeurId: String
    let voyageurId: String
    let typeAnnonce: String
    let prixObjet: Double
    let fraisService: Double
    let prixTotal: Double
    let devise: String
    let statut: String
    let codeConfirmation: String
    let etapes: [Etape]
    let createdAt: String
}

struct Etape: Codable {
    let statut: String
    let date: String
}

// ── Livraison ─────────────────────────────────────────────
struct Livraison: Codable, Identifiable {
    let id: String
    let transactionId: String
    let annonceId: String
    let voyageurId: String
    let expediteurId: String
    let statut: String
    let etapes: [Etape]
    let createdAt: String
    let updatedAt: String
}

// ── Message ───────────────────────────────────────────────
struct Message: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let destinataireId: String
    let contenu: String
    let annonceId: String
    let lu: Bool
    let createdAt: String
}

struct Conversation: Codable, Identifiable {
    var id: String { conversationId }
    let conversationId: String
    let autreUserId: String
    let dernierMessage: String
    let annonceId: String
    let nonLus: Int
    let updatedAt: String
}

// ── Boost ─────────────────────────────────────────────────
struct Boost: Codable, Identifiable {
    let id: String
    let annonceId: String
    let userId: String
    let type: String
    let prix: Double
    let devise: String
    let dureeJours: Int
    let dateDebut: String
    let dateFin: String
    let actif: Bool
    let createdAt: String
}

struct BoostType: Codable {
    let prix: Double
    let duree_jours: Int
    let label: String
}

// ── Evaluation ────────────────────────────────────────────
struct Evaluation: Codable, Identifiable {
    let id: String
    let evaluateurId: String
    let evalueId: String
    let livraisonId: String
    let role: String
    let note: Int
    let commentaire: String
    let createdAt: String
}

struct EvaluationResult: Codable {
    let items: [Evaluation]
    let moyenne: Double
    let total: Int
}

// ── Tracking Colis ────────────────────────────────────────
struct ColisTracking: Codable {
    let code: String
    let livraisonId: String
    let annonceId: String
    let titre: String
    let villeDepart: String
    let villeArrivee: String
    let paysDepart: String
    let paysArrivee: String
    let poids: Double
    let categorie: String
    let statut: String
    let etapes: [Etape]
    let expediteurId: String
    let voyageurId: String
    let createdAt: String

    var codeFormate: String { ColisCodeGenerator.formatted(code) }
}

// ── Misc ──────────────────────────────────────────────────
struct Tags: Codable {
    let urgence: [String]
    let contenu: [String]
    let transport: [String]
    let situation: [String]
    let recompense: [String]

    var tous: [String] {
        urgence + contenu + transport + situation + recompense
    }
}

// ── Trajet ──────────────────────────────────────────────────

struct EtapeTrajet: Codable, Identifiable {
    var id: String { "\(ville)-\(pays)" }
    let ville: String
    let adresse: String?
    let pays: String
    let dateDepart: String?
}

struct Trajet: Codable, Identifiable {
    let id: String
    let voyageurId: String
    let villeDepart: String
    let villeArrivee: String
    let paysDepart: String
    let paysArrivee: String
    let dateDepart: String
    let dateArrivee: String
    let moyenTransport: String
    let poidsDisponible: Double
    let poidsRestant: Double
    let prixParKg: Double
    let categoriesAcceptees: [String]
    let etapes: [EtapeTrajet]?
    let statut: String
    let createdAt: String

    var isOuvert: Bool { statut == "ouvert" }
}
