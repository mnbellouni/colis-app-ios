import SwiftUI

struct MesAnnoncesView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @State private var annonces:     [Annonce] = []
    @State private var isLoading     = false
    @State private var error: String? = nil
    @State private var filtreStatut  = "toutes"
    @State private var annonceToDelete: Annonce? = nil

    let filtres = [("Toutes", "toutes"), ("Ouvertes", "ouverte"), ("Pourvues", "pourvue"), ("Fermées", "fermee")]

    var annoncesFiltered: [Annonce] {
        switch filtreStatut {
        case "ouverte": return annonces.filter { $0.statut == "ouverte" }
        case "pourvue": return annonces.filter { $0.statut == "pourvue" }
        case "fermee":  return annonces.filter { $0.statut == "fermee" }
        default:        return annonces
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView().tint(.appPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error {
                EmptyStateView(icon: "wifi.slash", title: "Erreur", message: error)
            } else if annonces.isEmpty {
                EmptyStateView(icon: "megaphone", title: "Aucune annonce",
                               message: "Vos annonces publiées apparaîtront ici.")
            } else {
                VStack(spacing: 0) {
                    // Filtres rapides
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filtres, id: \.0) { label, val in
                                FilterChip(label: label, isSelected: filtreStatut == val) {
                                    filtreStatut = val
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.vertical, 10)
                    .background(Color.appBackground)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(annoncesFiltered) { annonce in
                                NavigationLink {
                                    AnnonceDetailView(annonceId: annonce.id)
                                } label: {
                                    MesAnnoncesCard(annonce: annonce,
                                        onToggle: { Task { await toggleActif(annonce) } },
                                        onDelete: { annonceToDelete = annonce }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .refreshable { await load() }
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Mes annonces")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Supprimer l'annonce ?",
               isPresented: Binding(get: { annonceToDelete != nil }, set: { if !$0 { annonceToDelete = nil } })) {
            Button("Supprimer", role: .destructive) {
                if let a = annonceToDelete { Task { await deleteAnnonce(a) } }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action est irréversible.")
        }
        .task { await load() }
    }

    private func load() async {
        guard let userId = authState.userId else { return }
        isLoading = true
        error     = nil
        do {
            annonces = try await factory.makeAnnonceRepository().getMesAnnonces(demandeurId: userId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func toggleActif(_ annonce: Annonce) async {
        do {
            let updated = try await factory.makeAnnonceRepository().toggleActif(id: annonce.id)
            if let i = annonces.firstIndex(where: { $0.id == annonce.id }) {
                annonces[i] = updated
            }
        } catch {}
    }

    private func deleteAnnonce(_ annonce: Annonce) async {
        do {
            try await factory.makeAnnonceRepository().deleteAnnonce(id: annonce.id)
            annonces.removeAll { $0.id == annonce.id }
        } catch {}
        annonceToDelete = nil
    }
}

// ── Carte annonce propriétaire ────────────────────────────

struct MesAnnoncesCard: View {
    let annonce:  Annonce
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(annonce.titre)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        StatutBadge(statut: annonce.statut)
                        if !annonce.isActive {
                            Text("Inactive")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.appTextTertiary)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.appCanvas)
                                .cornerRadius(20)
                        }
                    }
                }
                Spacer()
                Text("\(Int(annonce.budgetTransport)) €")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appPrimary)
            }

            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11)).foregroundColor(.appTextTertiary)
                Text("\(annonce.paysDepart.flagEmoji) \(annonce.villeDepart) → \((annonce.paysArrivee ?? "").flagEmoji) \(annonce.villeArrivee ?? "")")
                    .font(.system(size: 12)).foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                Button(action: onToggle) {
                    Label(annonce.isActive ? "Désactiver" : "Activer",
                          systemImage: annonce.isActive ? "eye.slash" : "eye")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(annonce.isActive ? .appTextSecondary : .appPrimary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(annonce.isActive ? Color.appCanvas : Color.appPrimaryLight)
                        .cornerRadius(99)
                }
                .buttonStyle(.plain)

                if annonce.statut == "ouverte" {
                    Button(action: onDelete) {
                        Label("Supprimer", systemImage: "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appError)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.appErrorLight)
                            .cornerRadius(99)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
