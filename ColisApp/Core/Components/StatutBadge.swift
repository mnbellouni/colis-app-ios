import SwiftUI

// Couvre tous les statuts définis dans la spec :
// annonces : ouverte, pourvue, fermee, desactivee
// livraisons : en_attente, recupere, en_transit, livre, confirme, litige
// offres : en_attente, acceptee, refusee
// trajets : ouvert, complet, en_cours, termine
// certification : non_soumis, pending, verifie, rejete
struct StatutBadge: View {
    let statut: String

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(background)
            .cornerRadius(AppRadius.pill)
    }

    private var label: String {
        switch statut {
        case "ouverte":        return "Ouverte"
        case "pourvue":        return "Pourvue"
        case "fermee":         return "Fermée"
        case "desactivee":     return "Désactivée"
        case "en_attente":     return "En attente"
        case "recupere":       return "Récupéré"
        case "en_transit":     return "En transit"
        case "livre":          return "Livré"
        case "confirme":       return "Confirmé"
        case "litige":         return "Litige"
        case "ouvert":         return "Ouvert"
        case "complet":        return "Complet"
        case "en_cours":       return "En cours"
        case "termine":        return "Terminé"
        case "acceptee":       return "Acceptée"
        case "refusee":        return "Refusée"
        case "pending":        return "En vérification"
        case "verifie":        return "Vérifié"
        case "non_soumis":     return "Non soumis"
        case "rejete":         return "Rejeté"
        default:               return statut.replacingOccurrences(of: "_", with: " ")
        }
    }

    private var foreground: Color {
        switch statut {
        case "ouverte", "livre", "confirme", "ouvert", "pourvue", "verifie", "acceptee":
            return .appSuccess
        case "en_transit", "recupere", "en_cours":
            return .appInfo
        case "en_attente", "complet", "pending":
            return .appWarning
        case "litige", "fermee", "termine", "refusee", "rejete", "desactivee":
            return .appError
        default:
            return .appTextSecondary
        }
    }

    private var background: Color {
        switch statut {
        case "ouverte", "livre", "confirme", "ouvert", "pourvue", "verifie", "acceptee":
            return .appSuccessLight
        case "en_transit", "recupere", "en_cours":
            return .appInfoLight
        case "en_attente", "complet", "pending":
            return .appWarningLight
        case "litige", "fermee", "termine", "refusee", "rejete", "desactivee":
            return .appErrorLight
        default:
            return .appCanvas
        }
    }
}
