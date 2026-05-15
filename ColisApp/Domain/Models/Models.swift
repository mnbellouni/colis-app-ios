import Foundation

// ── User ──────────────────────────────────────────────────
struct User: Identifiable {
    let id: String
    let email: String
    let nom: String
    let prenom: String
    let telephone: String
    let telephoneVerifie: Bool
    let photo: String
    let bio: String
    let typeAbonnement: String?
    let noteVoyageur: Double
    let noteExpediteur: Double
    let nbLivraisons: Double
    let verified: Bool
    let actif: Bool
    let certificationStatus: String
    let createdAt: String

    var abonnement: String { typeAbonnement ?? "standard" }
    var isPro: Bool { abonnement == "pro" }
    var isPremium: Bool { abonnement == "premium" }
    var nomComplet: String { "\(prenom) \(nom)" }
}

extension User: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, email, nom, prenom, telephone, telephoneVerifie, photo, bio
        case typeAbonnement, noteVoyageur, noteExpediteur
        case nbLivraisons, verified, actif, certificationStatus, createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                  = try  c.decode(String.self, forKey: .id)
        email               = (try? c.decodeIfPresent(String.self, forKey: .email)) ?? ""
        nom                 = try  c.decode(String.self, forKey: .nom)
        prenom              = try  c.decode(String.self, forKey: .prenom)
        telephone           = (try? c.decodeIfPresent(String.self, forKey: .telephone)) ?? ""
        telephoneVerifie    = (try? c.decodeIfPresent(Bool.self,   forKey: .telephoneVerifie)) ?? false
        photo               = (try? c.decodeIfPresent(String.self, forKey: .photo)) ?? ""
        bio                 = (try? c.decodeIfPresent(String.self, forKey: .bio)) ?? ""
        typeAbonnement      = try? c.decodeIfPresent(String.self, forKey: .typeAbonnement)
        noteVoyageur        = (try? c.decodeIfPresent(Double.self, forKey: .noteVoyageur)) ?? 0
        noteExpediteur      = (try? c.decodeIfPresent(Double.self, forKey: .noteExpediteur)) ?? 0
        nbLivraisons        = (try? c.decodeIfPresent(Double.self, forKey: .nbLivraisons)) ?? 0
        verified            = (try? c.decodeIfPresent(Bool.self, forKey: .verified)) ?? false
        actif               = (try? c.decodeIfPresent(Bool.self, forKey: .actif)) ?? true
        certificationStatus = (try? c.decodeIfPresent(String.self, forKey: .certificationStatus)) ?? "non_soumis"
        createdAt           = (try? c.decodeIfPresent(String.self, forKey: .createdAt)) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                  forKey: .id)
        try c.encode(email,               forKey: .email)
        try c.encode(nom,                 forKey: .nom)
        try c.encode(prenom,              forKey: .prenom)
        try c.encode(telephone,           forKey: .telephone)
        try c.encode(telephoneVerifie,    forKey: .telephoneVerifie)
        try c.encode(photo,               forKey: .photo)
        try c.encode(bio,                 forKey: .bio)
        try c.encodeIfPresent(typeAbonnement, forKey: .typeAbonnement)
        try c.encode(noteVoyageur,        forKey: .noteVoyageur)
        try c.encode(noteExpediteur,      forKey: .noteExpediteur)
        try c.encode(nbLivraisons,        forKey: .nbLivraisons)
        try c.encode(verified,            forKey: .verified)
        try c.encode(actif,               forKey: .actif)
        try c.encode(certificationStatus, forKey: .certificationStatus)
        try c.encode(createdAt,           forKey: .createdAt)
    }
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

// ── Pays ──────────────────────────────────────────────────
struct Pays: Codable, Identifiable, Hashable {
    let code: String
    let nom: String
    let indicatif: String
    let emoji: String
    let zone: String
    let nomZone: String
    var id: String { code }

    var affichage: String { "\(emoji) \(nom)" }
    var indicatifFormate: String { "\(emoji) \(indicatif)" }

    static let defauts: [Pays] = [
        Pays(code: "FR", nom: "France",    indicatif: "+33",  emoji: "🇫🇷", zone: "EU", nomZone: "Europe"),
        Pays(code: "DZ", nom: "Algérie",   indicatif: "+213", emoji: "🇩🇿", zone: "NA", nomZone: "Afrique du Nord"),
        Pays(code: "MA", nom: "Maroc",     indicatif: "+212", emoji: "🇲🇦", zone: "NA", nomZone: "Afrique du Nord"),
        Pays(code: "TN", nom: "Tunisie",   indicatif: "+216", emoji: "🇹🇳", zone: "NA", nomZone: "Afrique du Nord"),
        Pays(code: "BE", nom: "Belgique",  indicatif: "+32",  emoji: "🇧🇪", zone: "EU", nomZone: "Europe"),
        Pays(code: "DE", nom: "Allemagne", indicatif: "+49",  emoji: "🇩🇪", zone: "EU", nomZone: "Europe"),
    ]
}

// ── Config (chargée au lancement, mise en cache) ───────────
struct TagItem: Codable, Identifiable, Hashable {
    let id: String
    let label: String
}

struct RemoteConfig: Codable {
    let tags: TagsConfig
    let pays: [Pays]

    struct TagsConfig: Codable {
        let urgence: [TagItem]
        let contenu: [TagItem]
        let dimensions: [TagItem]

        var tous: [TagItem] { urgence + contenu + dimensions }

        func label(for id: String) -> String {
            tous.first { $0.id == id }?.label ?? id
        }
    }

    static let vide = RemoteConfig(
        tags: TagsConfig(urgence: [], contenu: [], dimensions: []),
        pays: []
    )
}

// ── Annonce ───────────────────────────────────────────────
struct Annonce: Identifiable {
    let id: String
    let type: String
    let demandeurId: String
    let titre: String
    let description: String
    let photos: [String]
    let categories: [String]
    let tags: [String]
    let priorite: String
    let poids: Double
    let fragile: Bool
    let budgetTransport: Double
    let devise: String
    let dateLimite: String
    let statut: String
    let actif: Bool?
    let avecCodeSuivi: Bool?
    let boost: Bool
    let nbOffres: Double
    let paysDepart: String
    let villeDepart: String
    let adresseDepart: String
    let nomExpediteur: String?
    let prenomExpediteur: String?
    let paysArrivee: String?
    let villeArrivee: String?
    let adresseArrivee: String?
    let nomDestinataire: String?
    let prenomDestinataire: String?
    let paysSource: String?
    let achat: Achat?
    let createdAt: String
    let updatedAt: String

    var isTransport: Bool { type == "transport" }
    var isAchat: Bool { type == "achat_transport" }
    var isUrgent: Bool { tags.contains("urgent") || tags.contains("tres_urgent") }
    var isBoosted: Bool { boost }
    var isActive: Bool { actif ?? true }
}

extension Annonce: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, type, demandeurId, titre, description, photos
        case categories, categorie
        case tags, priorite, poids, fragile, budgetTransport, devise
        case dateLimite, statut, actif, avecCodeSuivi, boost, nbOffres
        case paysDepart, villeDepart, adresseDepart
        case nomExpediteur, prenomExpediteur
        case paysArrivee, villeArrivee, adresseArrivee
        case nomDestinataire, prenomDestinataire
        case paysSource, achat, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        type          = try c.decode(String.self, forKey: .type)
        demandeurId   = try c.decode(String.self, forKey: .demandeurId)
        titre         = try c.decode(String.self, forKey: .titre)
        description   = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
        photos        = (try? c.decodeIfPresent([String].self, forKey: .photos)) ?? []
        // Rétrocompatibilité : anciens docs ont 'categorie' (String), nouveaux 'categories' ([String])
        if let cats = try? c.decodeIfPresent([String].self, forKey: .categories), !cats.isEmpty {
            categories = cats
        } else if let cat = try? c.decodeIfPresent(String.self, forKey: .categorie), !cat.isEmpty {
            categories = [cat]
        } else {
            categories = []
        }
        tags          = (try? c.decodeIfPresent([String].self, forKey: .tags)) ?? []
        priorite      = (try? c.decodeIfPresent(String.self, forKey: .priorite)) ?? "normale"
        poids         = (try? c.decodeIfPresent(Double.self, forKey: .poids)) ?? 0
        fragile       = (try? c.decodeIfPresent(Bool.self, forKey: .fragile)) ?? false
        budgetTransport = (try? c.decodeIfPresent(Double.self, forKey: .budgetTransport)) ?? 0
        devise        = (try? c.decodeIfPresent(String.self, forKey: .devise)) ?? "EUR"
        dateLimite    = (try? c.decodeIfPresent(String.self, forKey: .dateLimite)) ?? ""
        statut        = (try? c.decodeIfPresent(String.self, forKey: .statut)) ?? "ouverte"
        actif         = try? c.decodeIfPresent(Bool.self, forKey: .actif)
        avecCodeSuivi = try? c.decodeIfPresent(Bool.self, forKey: .avecCodeSuivi)
        boost         = (try? c.decodeIfPresent(Bool.self, forKey: .boost)) ?? false
        nbOffres      = (try? c.decodeIfPresent(Double.self, forKey: .nbOffres)) ?? 0
        paysDepart    = (try? c.decodeIfPresent(String.self, forKey: .paysDepart)) ?? ""
        villeDepart   = (try? c.decodeIfPresent(String.self, forKey: .villeDepart)) ?? ""
        adresseDepart = (try? c.decodeIfPresent(String.self, forKey: .adresseDepart)) ?? ""
        nomExpediteur    = try? c.decodeIfPresent(String.self, forKey: .nomExpediteur)
        prenomExpediteur = try? c.decodeIfPresent(String.self, forKey: .prenomExpediteur)
        paysArrivee      = try? c.decodeIfPresent(String.self, forKey: .paysArrivee)
        villeArrivee     = try? c.decodeIfPresent(String.self, forKey: .villeArrivee)
        adresseArrivee   = try? c.decodeIfPresent(String.self, forKey: .adresseArrivee)
        nomDestinataire  = try? c.decodeIfPresent(String.self, forKey: .nomDestinataire)
        prenomDestinataire = try? c.decodeIfPresent(String.self, forKey: .prenomDestinataire)
        paysSource    = try? c.decodeIfPresent(String.self, forKey: .paysSource)
        achat         = try? c.decodeIfPresent(Achat.self, forKey: .achat)
        createdAt     = (try? c.decodeIfPresent(String.self, forKey: .createdAt)) ?? ""
        updatedAt     = (try? c.decodeIfPresent(String.self, forKey: .updatedAt)) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,               forKey: .id)
        try c.encode(type,             forKey: .type)
        try c.encode(demandeurId,      forKey: .demandeurId)
        try c.encode(titre,            forKey: .titre)
        try c.encode(description,      forKey: .description)
        try c.encode(photos,           forKey: .photos)
        try c.encode(categories,       forKey: .categories)
        try c.encode(tags,             forKey: .tags)
        try c.encode(priorite,         forKey: .priorite)
        try c.encode(poids,            forKey: .poids)
        try c.encode(fragile,          forKey: .fragile)
        try c.encode(budgetTransport,  forKey: .budgetTransport)
        try c.encode(devise,           forKey: .devise)
        try c.encode(dateLimite,       forKey: .dateLimite)
        try c.encode(statut,           forKey: .statut)
        try c.encodeIfPresent(actif,             forKey: .actif)
        try c.encodeIfPresent(avecCodeSuivi,     forKey: .avecCodeSuivi)
        try c.encode(boost,            forKey: .boost)
        try c.encode(nbOffres,         forKey: .nbOffres)
        try c.encode(paysDepart,       forKey: .paysDepart)
        try c.encode(villeDepart,      forKey: .villeDepart)
        try c.encode(adresseDepart,    forKey: .adresseDepart)
        try c.encodeIfPresent(nomExpediteur,     forKey: .nomExpediteur)
        try c.encodeIfPresent(prenomExpediteur,  forKey: .prenomExpediteur)
        try c.encodeIfPresent(paysArrivee,       forKey: .paysArrivee)
        try c.encodeIfPresent(villeArrivee,      forKey: .villeArrivee)
        try c.encodeIfPresent(adresseArrivee,    forKey: .adresseArrivee)
        try c.encodeIfPresent(nomDestinataire,   forKey: .nomDestinataire)
        try c.encodeIfPresent(prenomDestinataire,forKey: .prenomDestinataire)
        try c.encodeIfPresent(paysSource,        forKey: .paysSource)
        try c.encodeIfPresent(achat,             forKey: .achat)
        try c.encode(createdAt,        forKey: .createdAt)
        try c.encode(updatedAt,        forKey: .updatedAt)
    }
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
    let trajetId: String?
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

struct Etape: Codable {
    let statut: String
    let date: String
}

// ── Livraison ─────────────────────────────────────────────
struct Livraison: Codable, Identifiable {
    let id: String
    let offreId: String
    let annonceId: String
    let trajetId: String?
    let voyageurId: String
    let expediteurId: String
    let prixConvenu: Double
    let devise: String
    // ColisCo Protect
    let codeLivraison: String?
    let codeLivraisonValide: Bool
    let codeSecretValide: Bool
    let litige: Bool
    let raisonLitige: String?
    let statut: String
    let etapes: [Etape]
    let createdAt: String
    let updatedAt: String

    var statutDisplay: String {
        switch statut {
        case "en_attente": return "En attente"
        case "recupere":   return "Récupéré"
        case "en_transit": return "En transit"
        case "livre":      return "Livré"
        case "confirme":   return "Confirmé"
        case "litige":     return "Litige"
        default:           return statut
        }
    }
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
    let prix: Double
    let devise: String
    let dureeJours: Int
    let dateDebut: String
    let dateFin: String
    let actif: Bool
    let createdAt: String
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
    let categories: [String]
    let statut: String
    let etapes: [Etape]
    let expediteurId: String
    let voyageurId: String
    let createdAt: String

    var codeFormate: String { ColisCodeGenerator.formatted(code) }
}


// ── Trajet ────────────────────────────────────────────────
struct EtapeTrajet: Codable, Identifiable {
    var id: String { "\(ville)-\(pays)" }
    let ville: String
    let adresse: String?
    let pays: String
    let dateDepart: String?
}

struct PrixPalier: Codable {
    let poidsMin: Double
    let poidsMax: Double
    let prix: Double
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
    let prixParKg: Double?
    let prixPaliers: [PrixPalier]?
    let categoriesAcceptees: [String]
    let etapes: [EtapeTrajet]?
    let statut: String
    let createdAt: String

    var isOuvert: Bool { statut == "ouvert" }
}

struct PagedResult<T: Codable>: Codable {
    let items: [T]
    let nextToken: String?
}

struct UploadUrlResponse: Decodable {
    let uploadUrl: String
    let photoUrl: String
    let key: String
    let expiresIn: Int
}
