import SwiftUI

// ── Carte Annonce ─────────────────────────────────────────
struct AnnonceCard: View {
    let annonce: Annonce
    var isFavori: Bool = false
    var onFavoriTap: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Thumbnail 74×74
            ZStack(alignment: .topLeading) {
                Group {
                    if let url = annonce.photos.first, let imageURL = URL(string: url) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                photoPlaceholder
                            }
                        }
                    } else {
                        photoPlaceholder
                    }
                }
                .frame(width: 74, height: 74)
                .clipped()
                .cornerRadius(14)

                // Badge URGENT sur thumbnail
                if annonce.isUrgent {
                    Text("URGENT")
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.appError)
                        .cornerRadius(4)
                        .offset(x: 4, y: 4)
                }
            }

            // Contenu (flex: 1)
            VStack(alignment: .leading, spacing: 0) {

                // Ligne 1: chips catégories (toutes)
                HStack(alignment: .top, spacing: 0) {
                    FlowLayout(spacing: 5) {
                        ForEach(annonce.categories, id: \.self) { categorie in
                            CategoryChip(label: categorie)
                        }
                    }
                    Spacer(minLength: 8)
                    Button {
                        onFavoriTap?()
                    } label: {
                        Image(systemName: isFavori ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isFavori ? .appError : .appTextTertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 5)

                // Titre (13px/700, 2 lignes max)
                Text(annonce.titre)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .padding(.bottom, 6)

                // Route (11px IS, icon 11px)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.appPrimary)
                    Text("\(annonce.villeDepart) → \(annonce.villeArrivee ?? "–") · \(String(format: "%.1f", annonce.poids)) kg")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                }
                .padding(.bottom, 6)

                Spacer(minLength: 0)

                // Pied: Avatar 20px + user name + étoiles + prix
                HStack(spacing: 6) {
                    AvatarView(seed: annonce.demandeurId, size: 20)
                    Text("Utilisateur")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                    HStack(spacing: 1) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.appWarning)
                        }
                    }
                    Spacer()
                    Text("\(Int(annonce.budgetTransport))€")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 2)
    }

    private var photoPlaceholder: some View {
        ZStack {
            placeholderBgColor
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 26))
                .foregroundColor(.appTextPrimary.opacity(0.35))
        }
    }

    private var placeholderBgColor: Color {
        let cat = annonce.categories.first?.lowercased() ?? ""
        switch cat {
        case "electronique", "telephone", "informatique": return .appInfoLight
        case "cosmetique", "beaute", "parfum":            return .appWarningLight
        case "vetements", "mode", "accessoires":          return .appAccentLight
        default:                                           return .appPrimaryLight
        }
    }
}

// ── Category Chip ─────────────────────────────────────────
struct CategoryChip: View {
    let label: String
    var style: ChipStyle = .category

    enum ChipStyle { case category, urgent }

    var body: some View {
        Text(label.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
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
            .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
            .background(
                Circle()
                    .stroke(avatarColor, lineWidth: 1.5)
                    .frame(width: size + 5, height: size + 5)
            )

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

