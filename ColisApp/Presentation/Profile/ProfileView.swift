import SwiftUI

struct ProfileView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<ProfileViewModel>()
    private var vm: ProfileViewModel? { vmHolder.vm }

    @State private var showEdit                     = false
    @State private var showCertification            = false
    @State private var showCreateTrajet             = false
    @State private var certificationStatus          = "non_soumis"
    @State private var certificationRejectionReason = ""
    @State private var trajetUtilises               = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── En-tête profil ────────────────────
                    VStack(spacing: 14) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(
                                seed: "\(authState.userPrenom ?? "")\(authState.userNom ?? "")",
                                size: 80
                            )
                            Button { showEdit = true } label: {
                                ZStack {
                                    Circle().fill(Color.appCard).frame(width: 28, height: 28)
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.appPrimary)
                                }
                            }
                            .offset(x: 4, y: 4)
                        }

                        VStack(spacing: 6) {
                            Text("\(authState.userPrenom ?? "") \(authState.userNom ?? "")")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appTextPrimary)

                            if let user = vm?.user {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.appWarning)
                                    Text(String(format: "%.1f", user.noteVoyageur))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.appTextPrimary)
                                    Text("· \(Int(user.nbLivraisons)) livraisons")
                                        .font(.system(size: 13))
                                        .foregroundColor(.appTextSecondary)
                                }
                            }

                            // Badges abonnement + certification
                            HStack(spacing: 8) {
                                if let user = vm?.user, user.abonnement != "standard" {
                                    Text(user.abonnement == "pro" ? "PRO" : "Premium")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(Color.appPrimary)
                                        .cornerRadius(99)
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: certificationIconName)
                                        .font(.system(size: 12))
                                    Text(certificationLabel)
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(certificationColor)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(certificationBackground)
                                .cornerRadius(99)
                            }
                        }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 24)

                    // ── MON ACTIVITÉ ──────────────────────
                    SectionHeader(title: "MON ACTIVITÉ")

                    VStack(spacing: 1) {
                        NavigationLink {
                            MesAnnoncesView()
                        } label: {
                            ProfileMenuRow(
                                icon: "megaphone.fill", iconColor: .appPrimary,
                                label: "Mes annonces", subtitle: "Gérer mes annonces publiées"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            TrajetsView()
                        } label: {
                            ProfileMenuRow(
                                icon: "map.fill", iconColor: Color.appInfo,
                                label: "Mes trajets", subtitle: "Créer et gérer mes trajets"
                            )
                        }
                        .buttonStyle(.plain)


                    }
                    .background(Color.appCard)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)

                    // ── ÉTAT DE MON COMPTE ────────────────
                    SectionHeader(title: "ÉTAT DE MON COMPTE")

                    VStack(spacing: 0) {
                        let identityVerified = normalizedStatus == "verifie" || normalizedStatus == "verified"

                        // Téléphone
                        ProfileStatusRow(
                            icon: "phone.fill",
                            label: "Téléphone vérifié",
                            isVerified: vm?.user?.telephoneVerifie ?? false,
                            subtitle: nil,
                            ctaLabel: nil,
                            action: nil
                        )

                        Divider().padding(.leading, 66)

                        // Identité
                        ProfileStatusRow(
                            icon: "checkmark.shield.fill",
                            label: "Identité vérifiée",
                            isVerified: identityVerified,
                            subtitle: nil,
                            ctaLabel: identityVerified ? nil : "Vérifier",
                            action: identityVerified ? nil : { showCertification = true }
                        )

                        Divider().padding(.leading, 66)

                        // Trajets actifs
                        ProfileStatusRow(
                            icon: "map.fill",
                            label: "Trajets actifs ce mois",
                            isVerified: false,
                            subtitle: "\(trajetUtilises) / 2",
                            ctaLabel: "+",
                            action: { showCreateTrajet = true }
                        )

                        Divider().padding(.leading, 66)

                        // Livraisons avec code
                        ProfileStatusRow(
                            icon: "lock.shield.fill",
                            label: "Livraisons avec code",
                            isVerified: (vm?.user?.nbLivraisons ?? 0) > 0,
                            subtitle: "\(Int(vm?.user?.nbLivraisons ?? 0))",
                            ctaLabel: nil,
                            action: nil
                        )
                    }
                    .background(Color.appCard)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)

                    // ── MON COMPTE ────────────────────────
                    SectionHeader(title: "MON COMPTE")

                    VStack(spacing: 1) {
                        ProfileMenuItem(
                            icon: "checkmark.shield.fill",
                            iconColor: certificationColor,
                            label: certificationMenuTitle,
                            subtitle: certificationMenuSubtitle,
                            badge: certificationIconName
                        ) {
                            showCertification = true
                        }

                        NavigationLink {
                            AbonnementView()
                        } label: {
                            ProfileMenuRow(
                                icon: "creditcard.fill", iconColor: .appAccent,
                                label: "Mon abonnement",
                                subtitle: abonnementSubtitle
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.appCard)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)

                    // ── Déconnexion ───────────────────────
                    Button {
                        Task { await vm?.logout(authState: authState) }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 15))
                            Text("Se déconnecter")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.appError)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appErrorLight)
                        .cornerRadius(13)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showEdit) {
                if let vm, let user = vm.user {
                    EditProfileView(user: user, vm: vm)
                }
            }
            .sheet(isPresented: $showCertification) {
                CertificationFlowView(
                    accountNom:    vm?.user?.nom ?? authState.userNom ?? "",
                    accountPrenom: vm?.user?.prenom ?? authState.userPrenom ?? "",
                    source:        "Profil",
                    isAlreadyVerified: vm?.user?.verified ?? false
                )
            }
            .sheet(isPresented: $showCreateTrajet) {
                CreateTrajetView(vm: factory.makeTrajetViewModel())
            }
            .refreshable {
                await vm?.loadProfile(userId: authState.userId ?? "")
                await loadCertificationStatus()
                await loadTrajetLimit()
            }
            .onChange(of: showCertification) {
                if !showCertification { Task { await loadCertificationStatus() } }
            }
            .onChange(of: showCreateTrajet) {
                if !showCreateTrajet { Task { await loadTrajetLimit() } }
            }
        }
        .task {
            vmHolder.vm = factory.makeProfileViewModel()
            await vm?.loadProfile(userId: authState.userId ?? "")
            await loadCertificationStatus()
            await loadTrajetLimit()
        }
    }

    // ── Helpers certification ─────────────────────────────

    private var normalizedStatus: String {
        certificationStatus
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }

    private var certificationLabel: String {
        switch normalizedStatus {
        case "verifie", "verified": return "Certifié"
        case "pending":             return "En attente"
        case "rejete", "rejected":  return "Refusé"
        default:                    return "Non certifié"
        }
    }

    private var certificationIconName: String {
        switch normalizedStatus {
        case "verifie", "verified": return "checkmark.seal.fill"
        case "pending":             return "hourglass"
        default:                    return "exclamationmark.triangle.fill"
        }
    }

    private var certificationColor: Color {
        switch normalizedStatus {
        case "verifie", "verified": return .appSuccess
        case "pending":             return .appWarning
        default:                    return .appError
        }
    }

    private var certificationBackground: Color {
        switch normalizedStatus {
        case "verifie", "verified": return .appSuccessLight
        case "pending":             return .appWarningLight
        default:                    return .appErrorLight
        }
    }

    private var certificationMenuTitle: String {
        switch normalizedStatus {
        case "verifie", "verified": return "Vérification validée"
        case "pending":             return "Vérification en attente"
        case "rejete", "rejected":  return "Vérification refusée"
        default:                    return "Vérifier mon identité"
        }
    }

    private var certificationMenuSubtitle: String {
        switch normalizedStatus {
        case "verifie", "verified": return "Compte certifié"
        case "pending":             return "Dossier en cours de revue"
        case "rejete", "rejected":  return certificationRejectionReason.isEmpty
            ? "Motif requis pour relancer"
            : certificationRejectionReason
        default:                    return "Documents d'identité requis"
        }
    }

    private var abonnementSubtitle: String {
        guard let user = vm?.user else { return "Standard" }
        switch user.abonnement {
        case "premium": return "Premium · 9,99 €/mois"
        case "pro":     return "PRO · 29,99 €/mois"
        default:        return "Standard · Gratuit"
        }
    }

    private func loadTrajetLimit() async {
        guard authState.isLoggedIn,
              let token = KeychainStorage().get(forKey: KeychainStorage.Keys.accessToken),
              let url   = URL(string: APIEndpoints.trajetsLimit) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? 0),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }
        trajetUtilises = (json["utilises"] as? Int) ?? 0
    }

    private func loadCertificationStatus() async {
        guard authState.isLoggedIn,
              let userId = authState.userId,
              let token  = KeychainStorage().get(forKey: KeychainStorage.Keys.accessToken),
              let url    = URL(string: APIEndpoints.userCertification(id: userId)) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? 0),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }
            certificationStatus          = (json["certificationStatus"] as? String) ?? "non_soumis"
            certificationRejectionReason = (json["certificationRejectionReason"] as? String) ?? ""
        } catch {}
    }
}

// ── Section header ────────────────────────────────────────
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.appTextTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.bottom, 6)
    }
}

// ── Menu item avec badge optionnel ────────────────────────
struct ProfileMenuItem: View {
    let icon:      String
    let iconColor: Color
    let label:     String
    let subtitle:  String
    var badge:     String? = nil
    let action:    () -> Void

    var body: some View {
        Button(action: action) {
            ProfileMenuRow(icon: icon, iconColor: iconColor, label: label, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }
}

struct ProfileMenuRow: View {
    let icon:      String
    let iconColor: Color
    let label:     String
    let subtitle:  String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.appTextTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.appTextTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// ── Edit Profile ──────────────────────────────────────────
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User
    @ObservedObject var vm: ProfileViewModel

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
                    AppButton(title: "Sauvegarder", action: {
                        Task {
                            await vm.updateProfile(
                                userId:    user.id,
                                nom:       nom.isEmpty       ? user.nom       : nom,
                                prenom:    prenom.isEmpty    ? user.prenom    : prenom,
                                telephone: telephone.isEmpty ? user.telephone : telephone,
                                bio:       bio.isEmpty       ? user.bio       : bio
                            )
                            dismiss()
                        }
                    }, isLoading: vm.isLoading)
                }
                .padding(18)
            }
            .background(Color.appBackground)
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton { dismiss() }
                }
            }
        }
        .onAppear { nom = user.nom; prenom = user.prenom; telephone = user.telephone; bio = user.bio }
    }
}

// ── Placeholder Abonnement ────────────────────────────────
struct AbonnementView: View {
    @EnvironmentObject private var authState: AuthState
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EmptyStateView(
                    icon: "creditcard",
                    title: "Mon abonnement",
                    message: "Gérez votre plan depuis cette section."
                )
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("Mon abonnement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ── Status Row ────────────────────────────────────────────
struct ProfileStatusRow: View {
    let icon:      String
    let label:     String
    let isVerified: Bool
    let subtitle:  String?       // valeur affichée sous le label
    let ctaLabel:  String?       // nil = pas de bouton ; "Vérifier", "+" etc.
    let action:    (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill((isVerified ? Color.appSuccess : Color.appTextTertiary).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isVerified ? .appSuccess : .appTextTertiary)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }
            }

            Spacer()

            if let ctaLabel, let action {
                Button(action: action) {
                    if ctaLabel == "+" {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.appPrimary)
                    } else {
                        Text(ctaLabel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.appPrimary)
                            .cornerRadius(99)
                    }
                }
            } else if isVerified {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.appSuccess)
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// ── Stat Card (utilisée dans d'autres vues) ───────────────
struct StatCard: View {
    let value: String
    let label: String
    var icon:  String? = nil

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(.appWarning)
                }
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
