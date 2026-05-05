import SwiftUI

struct ColisCodeView: View {

    let tracking: ColisTracking

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── En-tête ──────────────────────────
                VStack(spacing: 4) {
                    Text("Code Colis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    Text(tracking.codeFormate)
                        .font(.system(size: 36, weight: .heavy, design: .monospaced))
                        .foregroundColor(.appPrimary)
                        .kerning(4)
                    Text("Écrivez ce code sur votre colis")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextTertiary)
                }
                .padding(.top, 12)

                Divider()

                // ── Résumé colis ──────────────────────
                VStack(spacing: 16) {
                    Text("Résumé du colis")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    infoRow(icon: "shippingbox",    label: "Titre",     value: tracking.titre)
                    infoRow(icon: "scalemass",      label: "Poids",     value: "\(String(format: "%.1f", tracking.poids)) kg")
                    infoRow(icon: "tag",            label: "Catégorie", value: tracking.categorie.capitalized)

                    Divider()

                    HStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 10, height: 10)
                            Rectangle()
                                .fill(Color.appBorder)
                                .frame(width: 1, height: 24)
                            Circle()
                                .fill(Color.appSuccess)
                                .frame(width: 10, height: 10)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            Text("\(tracking.paysDepart.flagEmoji) \(tracking.villeDepart)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            Text("\(tracking.paysArrivee.flagEmoji) \(tracking.villeArrivee)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    HStack {
                        Text("Statut")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        StatutBadge(statut: tracking.statut)
                    }
                }
                .padding(20)
                .background(Color.appCard)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 2)

                // ── Timeline ─────────────────────────
                if !tracking.etapes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suivi")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appTextSecondary)

                        ForEach(tracking.etapes.indices, id: \.self) { index in
                            EtapeRow(
                                etape:  tracking.etapes[index],
                                isLast: index == tracking.etapes.count - 1,
                                isDone: true
                            )
                        }
                    }
                    .padding(16)
                    .background(Color.appCard)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                }

                // ── Instructions ─────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Label("Instructions", systemImage: "info.circle")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    Text("Inscrivez le code \(tracking.codeFormate) en gros et lisiblement sur votre colis. Le voyageur et le destinataire pourront l'utiliser pour suivre la livraison.")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(16)
                .background(Color.appPrimaryLight)
                .cornerRadius(12)
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("Fiche colis")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.appPrimary)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.appTextSecondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
            Spacer()
        }
    }
}
