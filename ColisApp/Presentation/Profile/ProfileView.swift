import SwiftUI

struct ProfileView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<ProfileViewModel>()
    private var vm: ProfileViewModel? { vmHolder.vm }
    @State private var showEdit = false
    @State private var showCertification = false
    @State private var certificationStatus = "non_soumis"
    @State private var certificationRejectionReason = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── Avatar + Identité ─────────────────
                    VStack(spacing: 14) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(seed: "\(authState.userPrenom ?? "")\(authState.userNom ?? "")", size: 80)
                            ZStack {
                                Circle().fill(Color.appCard).frame(width: 26, height: 26)
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.appPrimary)
                            }
                            .offset(x: 4, y: 4)
                        }

                        VStack(spacing: 6) {
                            Text("\(authState.userPrenom ?? "") \(authState.userNom ?? "")")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appTextPrimary)

                            if let user = vm?.user {
                                Text(user.email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                            }

                            HStack(spacing: 8) {
                                Text(certificationStatusLabel)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(certificationStatusColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(certificationStatusBackground)
                                    .cornerRadius(99)
                                if let user = vm?.user, !user.typeCompte.isEmpty {
                                    Text(user.typeCompte.capitalized)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.appTextSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.appCanvas)
                                        .cornerRadius(99)
                                }
                            }
                        }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                    // ── Stats ─────────────────────────────
                    if let user = vm?.user {
                        HStack(spacing: 0) {
                            StatCard(value: "\(Int(user.nbLivraisons))", label: "Tous")
                            Divider().frame(height: 36)
                            StatCard(
                                value: String(format: "%.1f", user.noteExpediteur),
                                label: "Expéditeur",
                                icon: "star.fill"
                            )
                            Divider().frame(height: 36)
                            StatCard(
                                value: String(format: "%.1f", user.noteVoyageur),
                                label: "Voyageur",
                                icon: "star.fill"
                            )
                        }
                        .padding(.vertical, 16)
                        .background(Color.appCard)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                    }

                    // ── Menu ──────────────────────────────
                    VStack(spacing: 1) {
                        ProfileMenuItem(
                            icon: "pencil.circle.fill", iconColor: .appPrimary,
                            label: "Modifier le profil", subtitle: "Nom, photo, bio"
                        ) { showEdit = true }

                        NavigationLink {
                            MesLivraisonsView()
                        } label: {
                            ProfileMenuRow(
                                icon: "shippingbox.fill", iconColor: .appInfo,
                                label: "Mes livraisons", subtitle: "Historique complet"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            SuiviColisView()
                                .navigationBarHidden(false)
                        } label: {
                            ProfileMenuRow(
                                icon: "qrcode", iconColor: Color(hex: "8B5CF6"),
                                label: "Mes codes de suivi", subtitle: "Codes actifs"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            TrajetsView()
                        } label: {
                            ProfileMenuRow(
                                icon: "map.fill", iconColor: Color(hex: "0EA5E9"),
                                label: "Mes trajets", subtitle: "Créer et gérer mes trajets"
                            )
                        }
                        .buttonStyle(.plain)

                        ProfileMenuItem(
                            icon: "checkmark.shield.fill",
                            iconColor: certificationStatusColor,
                            label: certificationMenuTitle,
                            subtitle: certificationMenuSubtitle
                        ) {
                            showCertification = true
                        }

                        ProfileMenuItem(
                            icon: "star.fill", iconColor: Color(hex: "F59E0B"),
                            label: "Évaluations", subtitle: "\(vm?.evaluations?.total ?? 0) avis"
                        ) { }

                        ProfileMenuItem(
                            icon: "creditcard.fill", iconColor: .appAccent,
                            label: "Paiements & sécurité", subtitle: "Moyens de paiement"
                        ) { }

                        ProfileMenuItem(
                            icon: "bell.fill", iconColor: .appWarning,
                            label: "Notifications", subtitle: "Gérer les alertes"
                        ) { }
                    }
                    .background(Color.appCard)
                    .cornerRadius(26)
                    .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.appBorder, lineWidth: 1))
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
                    accountNom: vm?.user?.nom ?? authState.userNom ?? "",
                    accountPrenom: vm?.user?.prenom ?? authState.userPrenom ?? "",
                    source: "Profil",
                    isAlreadyVerified: vm?.user?.verified ?? false
                )
            }
            .refreshable {
                await vm?.loadProfile(userId: authState.userId ?? "")
                await loadCertificationStatus()
            }
            .onChange(of: showCertification) { isPresented in
                if !isPresented {
                    Task { await loadCertificationStatus() }
                }
            }
        }
        .task {
            vmHolder.vm = factory.makeProfileViewModel()
            await vm?.loadProfile(userId: authState.userId ?? "")
            await loadCertificationStatus()
        }
    }

    private var certificationStatusLabel: String {
        switch normalizedCertificationStatus {
        case "verifie", "verified": return "Vérifié"
        case "pending": return "En attente"
        case "rejete", "rejected": return "Refusé"
        default: return "Non vérifié"
        }
    }

    private var certificationStatusColor: Color {
        switch normalizedCertificationStatus {
        case "verifie", "verified": return .appSuccess
        case "pending": return .appPrimary
        case "rejete", "rejected": return .appError
        default: return .appWarning
        }
    }

    private var certificationStatusBackground: Color {
        switch normalizedCertificationStatus {
        case "verifie", "verified": return .appSuccessLight
        case "pending": return .appPrimaryLight
        case "rejete", "rejected": return .appErrorLight
        default: return .appWarningLight
        }
    }

    private var certificationMenuTitle: String {
        switch normalizedCertificationStatus {
        case "verifie", "verified": return "Vérification validée"
        case "pending": return "Vérification en attente"
        case "rejete", "rejected": return "Vérification refusée"
        default: return "Vérifier mon identité"
        }
    }

    private var certificationMenuSubtitle: String {
        switch normalizedCertificationStatus {
        case "verifie", "verified": return "Compte certifié"
        case "pending": return "Dossier en cours de revue"
        case "rejete", "rejected":
            return certificationRejectionReason.isEmpty
                ? "Motif requis pour relancer"
                : certificationRejectionReason
        default: return "Documents d'identité requis"
        }
    }

    private var normalizedCertificationStatus: String {
        certificationStatus
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }

    private func loadCertificationStatus() async {
        guard authState.isLoggedIn,
              let userId = authState.userId,
              let token = KeychainStorage().get(forKey: KeychainStorage.Keys.accessToken),
              let url = URL(string: APIEndpoints.userCertification(id: userId)) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }

            certificationStatus = (json["certificationStatus"] as? String) ?? "non_soumis"
            certificationRejectionReason = (json["certificationRejectionReason"] as? String) ?? ""
        } catch {
            // Keep previous status on transient network errors.
        }
    }
}

// ── Stat Card ─────────────────────────────────────────────
struct StatCard: View {
    let value: String
    let label: String
    var icon: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// ── Menu Item ─────────────────────────────────────────────
struct ProfileMenuItem: View {
    let icon:      String
    let iconColor: Color
    let label:     String
    let subtitle:  String
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

// ── Evaluation Row ────────────────────────────────────────
struct EvaluationRow: View {
    let evaluation: Evaluation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<evaluation.note, id: \.self) { _ in
                        Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(Color(hex: "F59E0B"))
                    }
                }
                Spacer()
                Text(String(evaluation.createdAt.prefix(10))).font(.system(size: 12)).foregroundColor(.appTextTertiary)
            }
            if !evaluation.commentaire.isEmpty {
                Text(evaluation.commentaire).font(.system(size: 14)).foregroundColor(.appTextSecondary)
            }
        }
        .padding(12)
        .background(Color.appCanvas)
        .cornerRadius(10)
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
                    Button("Annuler") { dismiss() }.foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear { nom = user.nom; prenom = user.prenom; telephone = user.telephone; bio = user.bio }
    }
}

// ── Certification Flow ───────────────────────────────────
struct CertificationFlowView: View {

    @Environment(\.dismiss)        private var dismiss
    @EnvironmentObject private var authState: AuthState

    let accountNom: String
    let accountPrenom: String
    let source: String
    var isAlreadyVerified: Bool = false
    var onDone: (() -> Void)? = nil

    @State private var docType = "Carte d'identité"
    @State private var documentNumber = ""
    @State private var documentFrontRef = ""
    @State private var documentBackRef = ""
    @State private var firstNameOnDocument = ""
    @State private var lastNameOnDocument = ""
    @State private var submitted = false
    @State private var error: String? = nil
    @State private var certificationStatus = "non_soumis"
    @State private var rejectionReason = ""

    private let documentTypes = ["Carte d'identité", "Passeport", "Titre de séjour"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Certification d'identité")
                        .font(.system(size: 22, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Origine: \(source)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if normalizedCertificationStatus == "verifie" || normalizedCertificationStatus == "verified" || isAlreadyVerified {
                        Label("Votre compte est déjà certifié", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appSuccess)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.appSuccessLight)
                            .cornerRadius(12)
                    } else if normalizedCertificationStatus == "pending" {
                        Label("Votre dossier est en attente de validation admin", systemImage: "hourglass")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.appPrimaryLight)
                            .cornerRadius(12)
                    } else {
                        if normalizedCertificationStatus == "rejete" || normalizedCertificationStatus == "rejected" {
                            Label(
                                rejectionReason.isEmpty
                                    ? "Dossier refusé. Merci de corriger et renvoyer."
                                    : "Dossier refusé : \(rejectionReason)",
                                systemImage: "xmark.seal"
                            )
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.appErrorLight)
                            .cornerRadius(12)
                        }

                        if !authState.isLoggedIn || authState.userId == nil {
                            Text("Connectez-vous pour soumettre vos documents. Vous pourrez reprendre ce parcours depuis Profil ou Trajets.")
                                .font(.system(size: 13))
                                .foregroundColor(.appTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.appWarningLight)
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Type de document")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Picker("", selection: $docType) {
                                ForEach(documentTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        AppTextField(
                            title: "Numéro du document",
                            placeholder: "AB123456",
                            text: $documentNumber
                        )

                        AppTextField(
                            title: "Référence document recto",
                            placeholder: "Nom du fichier ou identifiant",
                            text: $documentFrontRef
                        )

                        AppTextField(
                            title: "Référence document verso",
                            placeholder: "Nom du fichier ou identifiant",
                            text: $documentBackRef
                        )

                        AppTextField(
                            title: "Prénom sur le document",
                            placeholder: accountPrenom,
                            text: $firstNameOnDocument
                        )

                        AppTextField(
                            title: "Nom sur le document",
                            placeholder: accountNom,
                            text: $lastNameOnDocument
                        )

                        if let error {
                            ErrorBanner(message: error)
                        }

                        if submitted {
                            Label("Dossier de certification enregistré. Vous serez notifié après vérification.", systemImage: "hourglass")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.appPrimaryLight)
                                .cornerRadius(12)
                        }

                        AppButton(title: "Soumettre mon dossier") {
                            Task {
                                await submitCertification()
                            }
                        }
                    }

                    AppButton(title: "Terminer", action: {
                        dismiss()
                        onDone?()
                    }, style: .secondary)
                }
                .padding(18)
            }
            .background(Color.appBackground)
            .navigationTitle("Certification")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            firstNameOnDocument = accountPrenom
            lastNameOnDocument = accountNom
        }
        .task {
            await loadCertificationStatus()
        }
    }

    private func submitCertification() async {
        error = nil
        submitted = false

        guard authState.isLoggedIn, let userId = authState.userId else {
            error = "Connectez-vous pour soumettre vos documents."
            return
        }

        guard !documentNumber.isEmpty,
              !documentFrontRef.isEmpty,
              !documentBackRef.isEmpty,
              !firstNameOnDocument.isEmpty,
              !lastNameOnDocument.isEmpty else {
            error = "Tous les champs du dossier sont obligatoires."
            return
        }

        guard normalize(firstNameOnDocument) == normalize(accountPrenom),
              normalize(lastNameOnDocument) == normalize(accountNom) else {
            error = "Le nom/prénom du document doit correspondre au compte."
            return
        }

        guard let token = KeychainStorage().get(forKey: KeychainStorage.Keys.accessToken) else {
            error = "Session expirée. Veuillez vous reconnecter."
            return
        }

        guard let url = URL(string: APIEndpoints.userCertification(id: userId)) else {
            error = "URL de certification invalide."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let payload: [String: String] = [
            "documentType": docType,
            "documentNumber": documentNumber,
            "documentFrontRef": documentFrontRef,
            "documentBackRef": documentBackRef,
            "firstNameOnDocument": firstNameOnDocument,
            "lastNameOnDocument": lastNameOnDocument,
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200...299).contains(code) {
                submitted = true
                await loadCertificationStatus()
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let backendError = json["erreur"] as? String,
               !backendError.isEmpty {
                error = backendError
            } else {
                error = "Échec de la soumission du dossier (\(code))."
            }
        } catch {
            self.error = "Impossible d'envoyer le dossier de certification."
        }
    }

    private func normalize(_ input: String) -> String {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }

    private var normalizedCertificationStatus: String {
        certificationStatus
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }

    private func loadCertificationStatus() async {
        guard authState.isLoggedIn,
              let userId = authState.userId,
              let token = KeychainStorage().get(forKey: KeychainStorage.Keys.accessToken),
              let url = URL(string: APIEndpoints.userCertification(id: userId)) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(code),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            certificationStatus = (json["certificationStatus"] as? String) ?? "non_soumis"
            rejectionReason = (json["certificationRejectionReason"] as? String) ?? ""
        } catch {
            // Keep optimistic UI state.
        }
    }
}
