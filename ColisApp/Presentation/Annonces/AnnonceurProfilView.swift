import SwiftUI

struct AnnonceurProfilView: View {

    @Environment(\.factory) private var factory
    let userId: String

    @StateObject private var vmHolder = VMHolder<AnnonceurProfilViewModel>()
    private var vm: AnnonceurProfilViewModel? { vmHolder.vm }

    var body: some View {
        ScrollView {
            if vm?.isLoading == true || vm == nil {
                ProgressView().padding(.top, 80)
            } else if let errorMsg = vm?.error {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundColor(.appTextTertiary)
                    Text(errorMsg)
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
                .padding(.horizontal, 32)
            } else if let user = vm?.user {
                VStack(spacing: 20) {
                    headerCard(user)
                    statsRow(user)
                    if !user.bio.isEmpty { bioSection(user) }
                    avisSection()
                }
                .padding(18)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vmHolder.vm = factory.makeAnnonceurProfilViewModel()
            await vmHolder.vm?.load(userId: userId)
        }
    }

    // ── Header ─────────────────────────────────────────────
    private func headerCard(_ user: User) -> some View {
        VStack(spacing: 14) {
            AvatarView(seed: userId, size: 72)

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text(user.nomComplet)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    if user.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.appPrimary)
                    }
                }

                if user.certificationStatus == "verifie" {
                    Text("Certifié ColisCo")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.appPrimaryLight)
                        .cornerRadius(20)
                }
            }

            // Étoiles
            let note = vm?.evaluations?.moyenne ?? user.noteExpediteur
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: Double(i) < note ? "star.fill" : "star")
                        .font(.system(size: 14))
                        .foregroundColor(.appWarning)
                }
                Text(String(format: "%.1f", note))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                    .padding(.leading, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.appCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
    }

    // ── Stats ──────────────────────────────────────────────
    private func statsRow(_ user: User) -> some View {
        HStack(spacing: 0) {
            statItem(value: "\(vm?.nbAnnonces ?? 0)", label: "Annonces")
            Divider().frame(height: 36)
            statItem(value: "\(Int(user.nbLivraisons))", label: "Livraisons")
            Divider().frame(height: 36)
            statItem(value: "\(vm?.evaluations?.total ?? 0)", label: "Avis")
        }
        .padding(.vertical, 16)
        .background(Color.appCard)
        .cornerRadius(13)
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appTextPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // ── Bio ────────────────────────────────────────────────
    private func bioSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("À propos")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            Text(user.bio)
                .font(.system(size: 14))
                .foregroundColor(.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(13)
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
    }

    // ── Avis ───────────────────────────────────────────────
    @ViewBuilder
    private func avisSection() -> some View {
        let items = vm?.evaluations?.items ?? []
        VStack(alignment: .leading, spacing: 12) {
            Text("Avis (\(vm?.evaluations?.total ?? 0))")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)

            if items.isEmpty {
                Text("Aucun avis pour le moment.")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.appCard)
                    .cornerRadius(13)
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
            } else {
                VStack(spacing: 10) {
                    ForEach(items) { eval in
                        avisRow(eval)
                    }
                }
            }
        }
    }

    private func avisRow(_ eval: Evaluation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < eval.note ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(.appWarning)
                    }
                }
                Spacer()
                Text(formattedDate(eval.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(.appTextTertiary)
            }
            if !eval.commentaire.isEmpty {
                Text(eval.commentaire)
                    .font(.system(size: 14))
                    .foregroundColor(.appTextPrimary)
            }
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(13)
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
    }

    private func formattedDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: iso) else { return "" }
        let out = DateFormatter()
        out.locale = Locale(identifier: "fr_FR")
        out.dateStyle = .medium
        return out.string(from: d)
    }
}
