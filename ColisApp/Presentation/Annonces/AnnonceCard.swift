import SwiftUI

struct AnnonceCard: View {
    let annonce: Annonce

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Header card ───────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(annonce.titre)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: typeIcon)
                            .font(.system(size: 11))
                            .foregroundColor(.appPrimary)
                        Text(typeLabel)
                            .font(.system(size: 12))
                            .foregroundColor(.appPrimary)
                    }
                }
                Spacer()

                // Prix
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(annonce.budgetTransport)) €")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appPrimary)
                    if annonce.isBoosted {
                        Text("⭐ Boosté")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.appWarning)
                    }
                }
            }

            // ── Route ─────────────────────────────────────
            HStack(spacing: 8) {
                RoutePoint(city: annonce.villeDepart, flag: annonce.paysDepart)
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextTertiary)
                RoutePoint(city: annonce.villeArrivee ?? "", flag: annonce.paysArrivee ?? "")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "scalemass")
                        .font(.system(size: 11))
                        .foregroundColor(.appTextTertiary)
                    Text("\(String(format: "%.1f", annonce.poids)) kg")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }
            }

            // ── Tags ──────────────────────────────────────
            if !annonce.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(annonce.tags.prefix(3), id: \.self) { tag in
                            TagBadge(tag: tag)
                        }
                    }
                }
            }

            // ── Footer ────────────────────────────────────
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                    Text("\(Int(annonce.nbOffres)) offre\(annonce.nbOffres > 1 ? "s" : "")")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }
                Spacer()
                StatutBadge(statut: annonce.statut)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var typeIcon: String {
        annonce.isAchat ? "bag.fill" : "shippingbox.fill"
    }

    private var typeLabel: String {
        annonce.isAchat ? "Achat + Transport" : "Transport"
    }
}

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

struct StatutBadge: View {
    let statut: String

    var body: some View {
        Text(statut.capitalized)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .cornerRadius(20)
    }

    private var color: Color {
        switch statut {
        case "ouverte":        return .appSuccess
        case "en_negociation": return .appWarning
        case "pourvue":        return .appPrimary
        default:               return .appTextSecondary
        }
    }

    private var backgroundColor: Color {
        switch statut {
        case "ouverte":        return .appSuccessLight
        case "en_negociation": return .appWarningLight
        case "pourvue":        return .appPrimaryLight
        default:               return .appBorder
        }
    }
}

extension String {
    var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in self.unicodeScalars {
            emoji.unicodeScalars.append(
                Unicode.Scalar(base + scalar.value)!
            )
        }
        return emoji
    }
}
