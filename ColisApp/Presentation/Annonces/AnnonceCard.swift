import SwiftUI

// ── Carte Annonce ─────────────────────────────────────────
struct AnnonceCard: View {
    let annonce: Annonce

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Chips catégorie + urgence | Favori
            HStack(spacing: 6) {
                CategoryChip(label: annonce.categorie)
                if annonce.isUrgent {
                    CategoryChip(label: "Urgent", style: .urgent)
                }
                Spacer()
                Image(systemName: "heart")
                    .font(.system(size: 16))
                    .foregroundColor(.appTextTertiary)
            }

            // Titre
            Text(annonce.titre)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appTextPrimary)
                .lineLimit(2)

            // Route + poids
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.appTextTertiary)
                Text("\(annonce.villeDepart) → \(annonce.villeArrivee ?? "–") · \(String(format: "%.1f", annonce.poids)) kg")
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }

            Divider()

            // Avatar + étoiles | Prix
            HStack(spacing: 8) {
                AvatarView(seed: annonce.demandeurId, size: 32)
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(Color(hex: "F59E0B"))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(Int(annonce.budgetTransport))€")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.appPrimary)
                    Text("budget")
                        .font(.system(size: 10))
                        .foregroundColor(.appTextTertiary)
                }
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 2)
    }
}

// ── Category Chip ─────────────────────────────────────────
struct CategoryChip: View {
    let label: String
    var style: ChipStyle = .category

    enum ChipStyle { case category, urgent }

    var body: some View {
        Text(label.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bgColor)
            .cornerRadius(99)
    }

    private var textColor: Color {
        style == .urgent ? .appError : categoryTextColor(label)
    }

    private var bgColor: Color {
        style == .urgent ? .appErrorLight : categoryBgColor(label)
    }

    private func categoryTextColor(_ cat: String) -> Color {
        switch cat.lowercased() {
        case "electronique", "telephone", "informatique": return .appInfo
        case "cosmetique", "beaute", "parfum":            return .appWarning
        case "vetements", "mode", "accessoires":          return .appAccent
        default:                                           return .appPrimary
        }
    }

    private func categoryBgColor(_ cat: String) -> Color {
        switch cat.lowercased() {
        case "electronique", "telephone", "informatique": return .appInfoLight
        case "cosmetique", "beaute", "parfum":            return .appWarningLight
        case "vetements", "mode", "accessoires":          return .appAccentLight
        default:                                           return .appPrimaryLight
        }
    }
}

// ── Avatar hue-based ──────────────────────────────────────
struct AvatarView: View {
    let seed: String
    var size: CGFloat = 44
    var showOnline: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle().fill(avatarColor)
                Text(initials)
                    .font(.system(size: size * 0.33, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)

            if showOnline {
                Circle()
                    .fill(Color.appSuccess)
                    .frame(width: size * 0.26, height: size * 0.26)
                    .overlay(Circle().stroke(Color.appCard, lineWidth: 2))
            }
        }
    }

    private var initials: String {
        let parts = seed.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init)
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(seed.prefix(2)).uppercased()
    }

    private var avatarColor: Color {
        let v = seed.unicodeScalars.first?.value ?? 65
        let hue = Double((v * 53) % 360) / 360.0
        return Color(hue: hue, saturation: 0.52, brightness: 0.68)
    }
}

// ── Statut Badge ──────────────────────────────────────────
struct StatutBadge: View {
    let statut: String

    var body: some View {
        Text(statut.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .cornerRadius(99)
    }

    private var color: Color {
        switch statut {
        case "ouverte", "livre", "confirme": return .appSuccess
        case "en_transit", "recupere":       return .appInfo
        case "en_attente", "en_negociation": return .appWarning
        case "litige":                       return .appError
        default:                             return .appTextSecondary
        }
    }

    private var backgroundColor: Color {
        switch statut {
        case "ouverte", "livre", "confirme": return .appSuccessLight
        case "en_transit", "recupere":       return .appInfoLight
        case "en_attente", "en_negociation": return .appWarningLight
        case "litige":                       return .appErrorLight
        default:                             return .appBorder
        }
    }
}

// ── RoutePoint (compatibilité) ────────────────────────────
struct RoutePoint: View {
    let city: String
    let flag: String

    var body: some View {
        HStack(spacing: 4) {
            Text(flag.flagEmoji)
                .font(.system(size: 12))
            Text(city)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
    }
}

extension String {
    var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in self.unicodeScalars {
            emoji.unicodeScalars.append(Unicode.Scalar(base + scalar.value)!)
        }
        return emoji
    }
}
