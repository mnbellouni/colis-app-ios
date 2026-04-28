import SwiftUI

struct ProfileView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    @State private var vm: ProfileViewModel?
    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Avatar + Nom ──────────────────────
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimaryLight)
                                .frame(width: 80, height: 80)
                            Text("\(authState.userPrenom?.prefix(1) ?? "?")\(authState.userNom?.prefix(1) ?? "")")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.appPrimary)
                        }

                        VStack(spacing: 4) {
                            Text("\(authState.userPrenom ?? "") \(authState.userNom ?? "")")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                            if let user = vm?.user {
                                Text(user.email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                    }
                    .padding(.top, 20)

                    // ── Stats ─────────────────────────────
                    if let user = vm?.user {
                        HStack(spacing: 0) {
                            StatCard(
                                value: "\(Int(user.nbLivraisons))",
                                label: "Livraisons"
                            )
                            Divider().frame(height: 40)
                            StatCard(
                                value: String(format: "%.1f ⭐", user.noteVoyageur),
                                label: "Voyageur"
                            )
                            Divider().frame(height: 40)
                            StatCard(
                                value: String(format: "%.1f ⭐", user.noteExpediteur),
                                label: "Expéditeur"
                            )
                        }
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 4)
                    }

                    // ── Évaluations ───────────────────────
                    if let evals = vm?.evaluations, evals.total > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Évaluations (\(evals.total))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appTextPrimary)

                            ForEach(evals.items.prefix(3)) { eval in
                                EvaluationRow(evaluation: eval)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }

                    // ── Actions ───────────────────────────
                    VStack(spacing: 12) {
                        ProfileAction(
                            icon:  "pencil",
                            label: "Modifier le profil",
                            color: .appPrimary
                        ) {
                            showEdit = true
                        }
                        .navigationDestination(isPresented: $showEdit) {
                            MesLivraisonsView()
                        }

                        ProfileAction(
                            icon:  "rectangle.portrait.and.arrow.right",
                            label: "Se déconnecter",
                            color: .appError
                        ) {
                            Task {
                                await vm?.logout(authState: authState)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.appBackground)
            .navigationTitle("Mon profil")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEdit) {
                if let user = vm?.user {
                    EditProfileView(user: user, vm: vm)
                }
            }
            .refreshable {
                await vm?.loadProfile(userId: authState.userId ?? "")
            }
        }
        .task {
            vm = factory.makeProfileViewModel()
            await vm?.loadProfile(userId: authState.userId ?? "")
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appTextPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileAction: View {
    let icon:   String
    let label:  String
    let color:  Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 32)
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(color == .appError ? .appError : .appTextPrimary)
                Spacer()
                if color != .appError {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        }
    }
}

struct EvaluationRow: View {
    let evaluation: Evaluation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(String(repeating: "⭐", count: evaluation.note))
                    .font(.system(size: 13))
                Spacer()
                Text(evaluation.createdAt.prefix(10))
                    .font(.system(size: 12))
                    .foregroundColor(.appTextTertiary)
            }
            if !evaluation.commentaire.isEmpty {
                Text(evaluation.commentaire)
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(12)
        .background(Color.appBackground)
        .cornerRadius(10)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User
    let vm: ProfileViewModel?

    @State private var nom       = ""
    @State private var prenom    = ""
    @State private var telephone = ""
    @State private var bio       = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppTextField(title: "Prénom",    placeholder: user.prenom,    text: $prenom)
                    AppTextField(title: "Nom",       placeholder: user.nom,       text: $nom)
                    AppTextField(title: "Téléphone", placeholder: user.telephone, text: $telephone)
                    AppTextField(title: "Bio",       placeholder: user.bio,       text: $bio)

                    AppButton(
                        title:     "Sauvegarder",
                        action: {
                            Task {
                                await vm?.updateProfile(
                                    userId:    user.id,
                                    nom:       nom.isEmpty       ? user.nom       : nom,
                                    prenom:    prenom.isEmpty    ? user.prenom    : prenom,
                                    telephone: telephone.isEmpty ? user.telephone : telephone,
                                    bio:       bio.isEmpty       ? user.bio       : bio
                                )
                                dismiss()
                            }
                        },
                        isLoading: vm?.isLoading ?? false
                    )
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear {
            nom       = user.nom
            prenom    = user.prenom
            telephone = user.telephone
            bio       = user.bio
        }
    }
}

