import SwiftUI
import PhotosUI

struct CreateAnnonceView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
    @EnvironmentObject private var configService: AppConfigService
    @Environment(\.dismiss)        private var dismiss

    @StateObject private var vmHolder = VMHolder<CreateAnnonceViewModel>()
    private var vm: CreateAnnonceViewModel? { vmHolder.vm }

    @State private var paysList: [Pays] = []
    @State private var step = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hideAnnonceOnboarding")
    @State private var hideOnboardingForever = false
    @State private var showTrajetsCompatibles = false
    @State private var stepError: String?     = nil
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var selectedPhotos: [UIImage]       = []

    let categories = ["vetements", "electronique", "medicament",
                      "documents", "alimentaire", "cosmetique", "cadeau", "autre"]

    private var tagsConfig: RemoteConfig.TagsConfig { configService.config.tags }

    var body: some View {
        NavigationStack {
            Group {
                if showOnboarding {
                    onboardingView
                } else if showTrajetsCompatibles, let vm {
                    TrajetsCompatiblesView(vm: vm, onDismiss: { dismiss() })
                } else {
                    formulaireView
                }
            }
        }
        .task {
            vmHolder.vm = factory.makeCreateAnnonceViewModel()
            let cfg = configService.config
            paysList = cfg.pays.isEmpty ? Pays.defauts : cfg.pays
        }
    }

    // ── Écran 0 : Onboarding ──────────────────────────────
    private var onboardingView: some View {
        ScrollView {
            VStack(spacing: 28) {

                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.appPrimaryLight)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.appPrimary.opacity(0.20), radius: 16, x: 0, y: 6)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 48)).foregroundColor(.appPrimary)
                }
                .padding(.top, 20)

                VStack(spacing: 10) {
                    Text("Envoyez votre colis,\nsimplement et en toute confiance")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                        .multilineTextAlignment(.center)
                    Text("Trouvez un voyageur qui passe par là où vous en avez besoin")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    onboardingStep(num: 1, icon: "doc.text.fill",
                                   title: "Décrivez votre colis",
                                   detail: "Quelques infos suffisent : type, poids, destination.")
                    onboardingStep(num: 2, icon: "envelope.fill",
                                   title: "Recevez des offres",
                                   detail: "Des transporteurs certifiés vous contactent et proposent leur prix.")
                    onboardingStep(num: 3, icon: "location.fill",
                                   title: "Suivez votre livraison",
                                   detail: "Acceptez une offre et suivez votre colis en temps réel.")
                }

                Text("Tous les transporteurs sont vérifiés et certifiés par ColisCo.")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextTertiary)
                    .multilineTextAlignment(.center)

                Toggle(isOn: $hideOnboardingForever) {
                    Text("Ne plus afficher cet écran")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .tint(.appPrimary)
                .padding(.horizontal, 4)

                VStack(spacing: 12) {
                    AppButton(title: "Je publie mon annonce") {
                        if hideOnboardingForever {
                            UserDefaults.standard.set(true, forKey: "hideAnnonceOnboarding")
                        }
                        showOnboarding = false
                    }
                    Button("Annuler") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground)
        .navigationTitle("Nouvelle annonce")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }
        }
    }

    private func onboardingStep(num: Int, icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.appPrimaryLight)
                    .frame(width: 44, height: 44)
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.appTextPrimary)
                Text(detail).font(.system(size: 12)).foregroundColor(.appTextSecondary)
            }
            Spacer()
        }
    }

    // ── Formulaire principal ──────────────────────────────
    private var formulaireView: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Barre de progression segmentée (DS: flex 1 / 4px / radius 99)
                StepProgressBar(step: step, total: 4)

                // Label étape
                HStack {
                    Text(stepTitles[safe: step] ?? "")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.appTextTertiary)
                        .textCase(.uppercase)
                        .tracking(0.06 * 11)
                    Spacer()
                    Text("Étape \(step + 1)/4")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.appTextTertiary)
                        .textCase(.uppercase)
                        .tracking(0.06 * 11)
                }

                switch step {
                case 0: stepType
                case 1: stepColis
                case 2: stepContacts
                case 3: stepOptions
                default: EmptyView()
                }

                if let error = vm?.error       { ErrorBanner(message: error) }
                if let error = stepError        { ErrorBanner(message: error) }

                HStack(spacing: 12) {
                    if step > 0 {
                        AppButton(title: "Retour", action: { step -= 1; stepError = nil }, style: .secondary)
                    }
                    if step < 3 {
                        AppButton(title: "Suivant", action: {
                            if let err = validateStep(step) { stepError = err }
                            else { stepError = nil; step += 1 }
                        })
                    } else {
                        AppButton(
                            title:     "Publier l'annonce",
                            action: {
                                Task {
                                    await vm?.createAnnonce(userId: authState.userId ?? "")
                                    if vm?.error == nil {
                                        if !selectedPhotos.isEmpty, let annonceId = vm?.annonce?.id {
                                            await vm?.uploadPhotos(selectedPhotos, annonceId: annonceId)
                                        }
                                        if vm?.trajetsCompatibles.isEmpty == false {
                                            showTrajetsCompatibles = true
                                        }
                                    }
                                }
                            },
                            isLoading: vm?.isLoading ?? false
                        )
                        if vm?.isLoading == true {
                            Text("Recherche de transporteurs compatibles…")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextTertiary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(Color.appBackground)
        .navigationTitle("Nouvelle annonce")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }
        }
        .onChange(of: vm?.isSuccess ?? false) {
            if vm?.isSuccess == true { dismiss() }
        }
    }

    private let stepTitles = ["Type d'annonce", "Informations colis", "Contacts & adresses", "Options"]

    // ── Étape 1 : Type ───────────────────────────────────
    private var stepType: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Type d'annonce")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.appTextPrimary)
                Text("Choisissez ce que vous souhaitez faire")
                    .font(.system(size: 14)).foregroundColor(.appTextSecondary)
            }

            VStack(spacing: 12) {
                TypeSelectionCard(
                    icon: "shippingbox.fill",
                    iconColor: Color.appPrimary,
                    title: "Transport",
                    subtitle: "Vous envoyez un colis existant",
                    selected: vm?.type == "transport"
                ) { vm?.type = "transport" }

                TypeSelectionCard(
                    icon: "bag.fill",
                    iconColor: Color.appAccent,
                    title: "Achat + Transport",
                    subtitle: "Vous souhaitez qu'on achète et ramène un produit",
                    selected: vm?.type == "achat_transport"
                ) { vm?.type = "achat_transport" }
            }
        }
    }

    // ── Étape 2 : Informations du colis ──────────────────
    private var stepColis: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Informations du colis")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.appTextPrimary)
            }

            // Photos (2 max)
            VStack(alignment: .leading, spacing: 8) {
                sectionLabel("Photos (facultatif, 2 max)")
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { slot in
                        if slot < selectedPhotos.count {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedPhotos[slot])
                                    .resizable().scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(13)
                                Button {
                                    selectedPhotos.remove(at: slot)
                                    if pickerItems.count > slot { pickerItems.remove(at: slot) }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                }
                                .offset(x: 6, y: -6)
                            }
                        } else {
                            PhotosPicker(
                                selection: $pickerItems,
                                maxSelectionCount: 2,
                                matching: .images
                            ) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 13)
                                        .fill(Color.appCanvas)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 13)
                                                .stroke(Color.appBorder, style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                        )
                                    VStack(spacing: 6) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 22)).foregroundColor(.appPrimary)
                                        Text("Ajouter")
                                            .font(.system(size: 11, weight: .medium)).foregroundColor(.appTextTertiary)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .onChange(of: pickerItems) {
                    Task {
                        var images: [UIImage] = []
                        for item in pickerItems.prefix(2) {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               data.count <= 10_485_760,
                               let img = UIImage(data: data) {
                                images.append(img)
                            }
                        }
                        selectedPhotos = images
                    }
                }
            }

            AppTextField(title: "Titre *", placeholder: "Ex: Colis vêtements famille",
                         text: Binding(get: { vm?.titre ?? "" }, set: { vm?.titre = $0 }))

            AppTextField(title: "Description", placeholder: "Décrivez votre colis…",
                         text: Binding(get: { vm?.description ?? "" }, set: { vm?.description = $0 }))

            // Catégories (multi-sélection obligatoire)
            VStack(alignment: .leading, spacing: 8) {
                sectionLabel("Catégories *")
                FlowLayout(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        FilterChip(
                            label: cat.capitalized,
                            isSelected: vm?.categories.contains(cat) ?? false
                        ) {
                            if vm?.categories.contains(cat) == true {
                                vm?.categories.removeAll { $0 == cat }
                            } else {
                                vm?.categories.append(cat)
                            }
                        }
                    }
                }
            }

            // Tags groupés (Urgence / Contenu / Dimensions)
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Tags")
                tagGroupSection("Urgence",    items: tagsConfig.urgence)
                tagGroupSection("Contenu",    items: tagsConfig.contenu)
                tagGroupSection("Dimensions", items: tagsConfig.dimensions)
            }

            HStack(spacing: 12) {
                AppTextField(title: "Poids (kg) *", placeholder: "2.5",
                             text: Binding(get: { vm?.poids ?? "" }, set: { vm?.poids = $0 }),
                             keyboardType: .decimalPad)
                AppTextField(title: "Budget (€) *", placeholder: "15",
                             text: Binding(get: { vm?.budget ?? "" }, set: { vm?.budget = $0 }),
                             keyboardType: .decimalPad)
            }

            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("Date limite")
                DatePicker("", selection: Binding(
                    get: { vm?.dateLimite ?? Date() },
                    set: { vm?.dateLimite = $0 }
                ), in: Date()..., displayedComponents: .date)
                .labelsHidden()
            }

            Toggle(isOn: Binding(get: { vm?.fragile ?? false }, set: { vm?.fragile = $0 })) {
                Label("Colis fragile", systemImage: "exclamationmark.triangle")
                    .font(.system(size: 15)).foregroundColor(.appTextPrimary)
            }
            .tint(.appWarning)
        }
    }

    @ViewBuilder
    private func tagGroupSection(_ titre: String, items: [TagItem]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(titre)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.appTextTertiary)
                    .textCase(.uppercase)
                    .tracking(0.05 * 11)
                FlowLayout(spacing: 8) {
                    ForEach(items) { item in
                        let selected = vm?.tags.contains(item.id) ?? false
                        FilterChip(label: item.label, isSelected: selected) {
                            if selected { vm?.tags.removeAll { $0 == item.id } }
                            else        { vm?.tags.append(item.id) }
                        }
                    }
                }
            }
        }
    }

    // ── Étape 3 : Contacts et adresses ───────────────────
    private var stepContacts: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Contacts et adresses")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.appTextPrimary)
            }

            // Bloc expéditeur
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Expéditeur")
                HStack(spacing: 12) {
                    AppTextField(title: "Prénom", placeholder: "Jean",
                                 text: Binding(get: { vm?.prenomExpediteur ?? "" }, set: { vm?.prenomExpediteur = $0 }))
                    AppTextField(title: "Nom", placeholder: "Dupont",
                                 text: Binding(get: { vm?.nomExpediteur ?? "" }, set: { vm?.nomExpediteur = $0 }))
                }
                PaysPickerInline(label: "Pays départ", pays: paysList,
                                 selection: Binding(get: { vm?.paysDepart ?? "FR" }, set: { vm?.paysDepart = $0 }))
                AppTextField(title: "Ville départ *", placeholder: "Paris",
                             text: Binding(get: { vm?.villeDepart ?? "" }, set: { vm?.villeDepart = $0 }))
                AppTextField(title: "Adresse départ", placeholder: "10 rue de la Paix",
                             text: Binding(get: { vm?.adresseDepart ?? "" }, set: { vm?.adresseDepart = $0 }))
            }
            .padding(14).background(Color.appCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))

            // Bloc destinataire
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Destinataire")
                HStack(spacing: 12) {
                    AppTextField(title: "Prénom", placeholder: "Marie",
                                 text: Binding(get: { vm?.prenomDestinataire ?? "" }, set: { vm?.prenomDestinataire = $0 }))
                    AppTextField(title: "Nom", placeholder: "Martin",
                                 text: Binding(get: { vm?.nomDestinataire ?? "" }, set: { vm?.nomDestinataire = $0 }))
                }
                PaysPickerInline(label: "Pays arrivée", pays: paysList,
                                 selection: Binding(get: { vm?.paysArrivee ?? "MA" }, set: { vm?.paysArrivee = $0 }))
                AppTextField(title: "Ville arrivée *", placeholder: "Casablanca",
                             text: Binding(get: { vm?.villeArrivee ?? "" }, set: { vm?.villeArrivee = $0 }))
                AppTextField(title: "Adresse arrivée", placeholder: "5 rue Hassan II",
                             text: Binding(get: { vm?.adresseArrivee ?? "" }, set: { vm?.adresseArrivee = $0 }))
            }
            .padding(14).background(Color.appCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
        }
    }

    // ── Étape 4 : Options de publication (OptionCard) ────
    private var stepOptions: some View {
        let codeSecret = vm?.avecCodeSecret ?? true
        let boost      = vm?.avecBoost      ?? false
        let total      = (codeSecret ? 0.99 : 0.0) + (boost ? 0.99 : 0.0)

        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Options de publication")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.appTextPrimary)
                Text("Ces options ne peuvent pas être activées après la publication.")
                    .font(.system(size: 13)).foregroundColor(.appTextSecondary)
            }

            // OptionCard — Code secret
            OptionCard(
                icon:      "lock.shield.fill",
                iconColor: Color.appShieldText,
                iconBg:    Color.appShieldBg,
                title:     "Protéger ma livraison",
                prix:      "0,99 €",
                selected:  codeSecret,
                features: [
                    "Code envoyé au destinataire au moment de la prise en charge",
                    "Le transporteur doit l'obtenir pour confirmer la livraison",
                    "Couvert en cas de litige via ColisCo"
                ],
                warning:  "Sans code secret, la livraison ne peut pas être confirmée via ColisCo"
            ) { vm?.avecCodeSecret.toggle() }

            // OptionCard — Boost
            OptionCard(
                icon:      "bolt.fill",
                iconColor: Color.appWarning,
                iconBg:    Color.appWarningLight,
                title:     "Booster l'annonce",
                prix:      "0,99 €",
                selected:  boost,
                features: [
                    "Votre annonce remonte en tête de la liste publique dès la publication",
                    "Les transporteurs Premium et PRO avec un trajet compatible sont contactés automatiquement",
                    "Matching continu sur tout nouveau trajet compatible créé après votre annonce"
                ]
            ) { vm?.avecBoost.toggle() }

            if total > 0 {
                HStack {
                    Spacer()
                    Text("Total : \(String(format: "%.2f", total).replacingOccurrences(of: ".", with: ",")) €")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
    }

    // ── Validation par étape ──────────────────────────────
    private func validateStep(_ step: Int) -> String? {
        switch step {
        case 0:
            guard vm?.type.isEmpty == false else { return "Choisissez un type d'annonce" }
            return nil
        case 1:
            guard vm?.titre.isEmpty == false else { return "Le titre est obligatoire" }
            guard vm?.categories.isEmpty == false else { return "Choisissez au moins une catégorie" }
            guard let poids = vm?.poids, !poids.isEmpty, Double(poids) != nil else { return "Le poids est obligatoire" }
            guard let budget = vm?.budget, !budget.isEmpty, Double(budget) != nil else { return "Le budget est obligatoire" }
            return nil
        case 2:
            guard vm?.villeDepart.isEmpty == false else { return "La ville de départ est obligatoire" }
            guard vm?.villeArrivee.isEmpty == false else { return "La ville d'arrivée est obligatoire" }
            return nil
        default:
            return nil
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.appTextSecondary)
    }
}

// ── Écran 5 : Transporteurs contactés ───────────────────────

struct TrajetsCompatiblesView: View {

    @ObservedObject var vm: CreateAnnonceViewModel
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Icône succès (DS: container 76×76 / radius 22 / bg appPrimaryLight / shadow)
                    VStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.appPrimaryLight)
                                .frame(width: 76, height: 76)
                                .shadow(color: Color.appPrimary.opacity(0.25), radius: 12, x: 0, y: 6)
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.appPrimary)
                        }

                        Text("Annonce publiée !")
                            .font(.system(size: 24, weight: .bold)).foregroundColor(.appTextPrimary)

                        let n = vm.trajetsCompatibles.count
                        Text("\(n) transporteur\(n > 1 ? "s ont été contactés" : " a été contacté") automatiquement.")
                            .font(.system(size: 13)).foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    // Liste des transporteurs
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transporteurs contactés")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.appTextPrimary)
                        ForEach(vm.trajetsCompatibles) { trajet in
                            TrajetContacteCard(trajet: trajet)
                        }
                    }

                    Text("Vous recevrez leurs réponses dans vos messages.")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextTertiary)
                        .multilineTextAlignment(.center)

                    AppButton(title: "OK, voir mon annonce", action: onDismiss)
                }
                .padding(18)
            }
            .background(Color.appBackground)
            .navigationTitle("Transporteurs contactés")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TrajetContacteCard: View {
    let trajet: Trajet

    var body: some View {
        HStack(spacing: 11) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(trajet.villeDepart) → \(trajet.villeArrivee)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.appTextPrimary)
                Text(String(trajet.dateDepart.prefix(10)))
                    .font(.system(size: 12)).foregroundColor(.appTextSecondary)
                if let prix = trajet.prixParKg {
                    Text("\(String(format: "%.2f", prix)) €/kg")
                        .font(.system(size: 12, weight: .medium)).foregroundColor(.appPrimary)
                }
            }
            Spacer()
            // Badge "Contacté ✓" (DS: écran publication réussie)
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                Text("Contacté")
                    .font(.system(size: 9, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.04 * 9)
            }
            .foregroundColor(.appSuccess)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.appSuccessLight)
            .cornerRadius(99)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color.appCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
    }
}

// ── Composants ────────────────────────────────────────────────

// Barre de progression segmentée (DS: flex 1, 4px, radius 99, gap 4)
struct StepProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 99)
                    .fill(i <= step ? Color.appPrimary : Color.appBorder)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.2), value: step)
            }
        }
    }
}

// Carte de sélection de type (étape 1)
struct TypeSelectionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let selected: Bool?
    let action: () -> Void

    var isSelected: Bool { selected ?? false }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icône 42×42 radius 13 (DS OptionCard)
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(isSelected ? iconColor : Color.appCanvas)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : .appTextSecondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
            }
            .padding(16)
            .background(Color.appCard)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? iconColor : Color.appBorder, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? iconColor.opacity(0.13) : Color.black.opacity(0.04),
                    radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// OptionCard — étape 4 options de publication (DS: OptionCard specs)
struct OptionCard: View {
    let icon:      String
    let iconColor: Color
    let iconBg:    Color
    let title:     String
    let prix:      String
    let selected:  Bool
    let features:  [String]
    var warning:   String? = nil
    let action:    () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {

                // Ligne principale : icône + titre + prix
                HStack(spacing: 14) {
                    // Icône 42×42 radius 13
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(selected ? iconColor : iconBg)
                            .frame(width: 42, height: 42)
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(selected ? .white : iconColor)
                    }
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Text(prix)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selected ? iconColor : .appTextSecondary)
                }

                // Features (indent sous le texte : 42 + 14 = 56)
                if !features.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(features, id: \.self) { feat in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(iconColor)
                                    .padding(.top, 1)
                                Text(feat)
                                    .font(.system(size: 11))
                                    .foregroundColor(.appTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 56)
                }

                // Bandeau warning (DS: appShieldBg, radius 8, margin-left 54)
                if let warning {
                    Text(warning)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(iconColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(iconBg)
                        .cornerRadius(8)
                        .padding(.leading, 56)
                }
            }
            .padding(16)
            .background(Color.appCard)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(selected ? iconColor : Color.appBorder, lineWidth: selected ? 2 : 1)
            )
            .shadow(color: selected ? iconColor.opacity(0.13) : Color.black.opacity(0.04),
                    radius: selected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// Sélecteur de pays inline
struct PaysPickerInline: View {
    let label:      String
    let pays:       [Pays]
    @Binding var selection: String

    @State private var showSheet = false

    private var selectedPays: Pays? { pays.first { $0.code == selection } }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            Button { showSheet = true } label: {
                HStack {
                    Text(selectedPays.map { "\($0.emoji) \($0.nom)" } ?? "Sélectionner")
                        .font(.system(size: 14))
                        .foregroundColor(selectedPays != nil ? .appTextPrimary : .appTextTertiary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextTertiary)
                }
                .padding(.horizontal, 13).padding(.vertical, 11)
                .background(Color.appCanvas)
                .cornerRadius(13)
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showSheet) {
            PaysSheetView(pays: pays, selection: $selection)
        }
    }
}

struct PaysSheetView: View {
    let pays: [Pays]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(pays) { p in
                Button {
                    selection = p.code
                    dismiss()
                } label: {
                    HStack {
                        Text("\(p.emoji) \(p.nom)")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextPrimary)
                        Spacer()
                        if p.code == selection {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
            }
            .navigationTitle("Choisir un pays")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton { dismiss() }
                }
            }
        }
    }
}
