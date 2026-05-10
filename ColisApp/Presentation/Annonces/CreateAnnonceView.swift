import SwiftUI
import PhotosUI

struct CreateAnnonceView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState
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
    let allTags = [
        "urgent", "tres_urgent", "medicament",
        "hospitalisation", "humanitaire", "lourd",
        "encombrant", "perissable", "valeur_elevee"
    ]

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
            paysList = (try? await factory.makePaysRepository().getPays()) ?? Pays.defauts
        }
    }

    // ── Écran 0 : Onboarding ──────────────────────────────
    private var onboardingView: some View {
        ScrollView {
            VStack(spacing: 28) {

                ZStack {
                    Circle().fill(Color.appPrimaryLight).frame(width: 120, height: 120)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 52)).foregroundColor(.appPrimary)
                }
                .padding(.top, 20)

                VStack(spacing: 10) {
                    Text("Envoyez votre colis,\nsimplement et en toute confiance")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                        .multilineTextAlignment(.center)
                    Text("Trouvez un voyageur qui passe par là où vous en avez besoin")
                        .font(.system(size: 15))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
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
                Circle().fill(Color.appPrimaryLight).frame(width: 44, height: 44)
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

                ProgressBar(step: step, total: 4)

                switch step {
                case 0: stepType
                case 1: stepColis
                case 2: stepContacts
                case 3: stepCodeSuivi
                default: EmptyView()
                }

                if let error = vm?.error {
                    ErrorBanner(message: error)
                }
                if let error = stepError {
                    ErrorBanner(message: error)
                }

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
                    }
                }
            }
            .padding(20)
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

    // ── Écran 1 : Type ────────────────────────────────────
    private var stepType: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Type d'annonce")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.appTextPrimary)
            Text("Choisissez ce que vous souhaitez faire")
                .font(.system(size: 14)).foregroundColor(.appTextSecondary)

            VStack(spacing: 12) {
                TypeCard(icon: "shippingbox.fill", title: "Transport",
                         subtitle: "Vous envoyez un colis existant",
                         selected: vm?.type == "transport") { vm?.type = "transport" }

                TypeCard(icon: "bag.fill", title: "Achat + Transport",
                         subtitle: "Vous souhaitez qu'on achète et ramène un produit",
                         selected: vm?.type == "achat_transport") { vm?.type = "achat_transport" }
            }
        }
    }

    // ── Écran 2 : Informations du colis ───────────────────
    private var stepColis: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations du colis")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.appTextPrimary)

            // Photos (2 max, JPG/PNG/HEIC, 10 Mo)
            VStack(alignment: .leading, spacing: 8) {
                Text("Photos (facultatif, 2 max)")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { slot in
                        if slot < selectedPhotos.count {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedPhotos[slot])
                                    .resizable().scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
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
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.appCanvas)
                                        .frame(width: 100, height: 100)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.appBorder, style: StrokeStyle(lineWidth: 1, dash: [4])))
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 22)).foregroundColor(.appPrimary)
                                        Text("Ajouter").font(.system(size: 11)).foregroundColor(.appTextTertiary)
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

            AppTextField(title: "Description", placeholder: "Décrivez votre colis...",
                         text: Binding(get: { vm?.description ?? "" }, set: { vm?.description = $0 }))

            VStack(alignment: .leading, spacing: 8) {
                Text("Catégories *").font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
                FlowLayout(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        FilterChip(label: cat.capitalized, isSelected: vm?.categories.contains(cat) ?? false) {
                            if vm?.categories.contains(cat) == true { vm?.categories.removeAll { $0 == cat } }
                            else { vm?.categories.append(cat) }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tags").font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
                FlowLayout(spacing: 8) {
                    ForEach(allTags, id: \.self) { tag in
                        FilterChip(label: tag.replacingOccurrences(of: "_", with: " ").capitalized,
                                   isSelected: vm?.tags.contains(tag) ?? false) {
                            if vm?.tags.contains(tag) == true { vm?.tags.removeAll { $0 == tag } }
                            else { vm?.tags.append(tag) }
                        }
                    }
                }
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
                Text("Date limite").font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
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
            .tint(.appPrimary)
        }
    }

    // ── Écran 3 : Contacts et adresses ───────────────────
    private var stepContacts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contacts et adresses")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.appTextPrimary)

            VStack(alignment: .leading, spacing: 10) {
                Text("Expéditeur").font(.system(size: 14, weight: .semibold)).foregroundColor(.appTextSecondary)
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
            .padding(14).background(Color.appCard).cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))

            VStack(alignment: .leading, spacing: 10) {
                Text("Destinataire").font(.system(size: 14, weight: .semibold)).foregroundColor(.appTextSecondary)
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
            .padding(14).background(Color.appCard).cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.appBorder, lineWidth: 1))
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

    // ── Écran 4 : Code de suivi ───────────────────────────
    private var stepCodeSuivi: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Option code de suivi")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.appTextPrimary)
            Text("Cette option ne peut pas être activée après la publication.")
                .font(.system(size: 13)).foregroundColor(.appTextSecondary)

            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: Binding(get: { vm?.avecCodeSuivi ?? false }, set: { vm?.avecCodeSuivi = $0 })) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Label("Code de suivi", systemImage: "qrcode")
                                .font(.system(size: 15, weight: .medium)).foregroundColor(.appTextPrimary)
                            Text("0,99 €")
                                .font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.appPrimary).cornerRadius(99)
                        }
                        Text("Code unique lié à votre colis. Suivi à chaque étape.")
                            .font(.system(size: 12)).foregroundColor(.appTextSecondary)
                    }
                }
                .tint(.appPrimary)
            }
            .padding(14).background(Color.appPrimaryLight).cornerRadius(13)
        }
    }
}

// ── Écran 5 : Trajets compatibles post-publication ────────

struct TrajetsCompatiblesView: View {

    @EnvironmentObject private var authState: AuthState
    @Environment(\.factory)        private var factory
    @ObservedObject var vm: CreateAnnonceViewModel
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 52)).foregroundColor(.appPrimary)
                        Text("Des transporteurs sont disponibles !")
                            .font(.system(size: 20, weight: .bold)).foregroundColor(.appTextPrimary)
                            .multilineTextAlignment(.center)
                        Text("Ces voyageurs font déjà le trajet. Voulez-vous leur envoyer une demande ?")
                            .font(.system(size: 14)).foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    ForEach(vm.trajetsCompatibles) { trajet in
                        TrajetSelectableCard(
                            trajet:   trajet,
                            selected: vm.trajetsSelectionnes.contains(trajet.id)
                        ) {
                            if vm.trajetsSelectionnes.contains(trajet.id) {
                                vm.trajetsSelectionnes.remove(trajet.id)
                            } else {
                                vm.trajetsSelectionnes.insert(trajet.id)
                            }
                        }
                    }

                    if vm.demandesEnvoyees {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 44)).foregroundColor(.appSuccess)
                            Text("Vos demandes ont été envoyées !")
                                .font(.system(size: 18, weight: .bold)).foregroundColor(.appTextPrimary)
                            Text("Retrouvez les réponses dans vos messages.")
                                .font(.system(size: 14)).foregroundColor(.appTextSecondary)
                            AppButton(title: "Retour à l'accueil", action: onDismiss)
                        }
                        .padding(.top, 20)
                    } else {
                        VStack(spacing: 12) {
                            AppButton(title: "Contacter les transporteurs sélectionnés",
                                      action: {
                                Task {
                                    await vm.envoyerDemandes(
                                        annonceId: vm.annonce?.id ?? "",
                                        userId: authState.userId ?? ""
                                    )
                                }
                            }, isLoading: vm.isLoading)
                            .disabled(vm.trajetsSelectionnes.isEmpty)

                            Button("Non merci, voir mon annonce") { onDismiss() }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Transporteurs disponibles")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TrajetSelectableCard: View {
    let trajet:   Trajet
    let selected: Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(selected ? .appPrimary : .appTextTertiary)
                VStack(alignment: .leading, spacing: 4) {
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
            }
            .padding(14)
            .background(Color.appCard)
            .cornerRadius(13)
            .overlay(RoundedRectangle(cornerRadius: 13)
                .stroke(selected ? Color.appPrimary : Color.appBorder,
                        lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}

// ── Composants locaux ─────────────────────────────────────

struct ProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Color.appBorder).frame(height: 4)
                RoundedRectangle(cornerRadius: 4).fill(Color.appPrimary)
                    .frame(width: geo.size.width * CGFloat(step + 1) / CGFloat(total), height: 4)
            }
        }
        .frame(height: 4)
    }
}

struct TypeCard: View {
    let icon: String; let title: String; let subtitle: String; let selected: Bool; let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(selected ? Color.appPrimary : Color.appCanvas).frame(width: 44, height: 44)
                    Image(systemName: icon).font(.system(size: 18)).foregroundColor(selected ? .white : .appTextSecondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(.appTextPrimary)
                    Text(subtitle).font(.system(size: 12)).foregroundColor(.appTextSecondary)
                }
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill").foregroundColor(.appPrimary) }
            }
            .padding(14).background(Color.appCard).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected ? Color.appPrimary : Color.appBorder, lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}

struct PaysPickerInline: View {
    let label: String; let pays: [Pays]; @Binding var selection: String

    @State private var showSheet = false

    private var selectedPays: Pays? { pays.first { $0.code == selection } }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(.appTextSecondary)
            Button { showSheet = true } label: {
                HStack {
                    Text(selectedPays.map { "\($0.code.flagEmoji) \($0.nom)" } ?? "Sélectionner")
                        .font(.system(size: 15))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBorder))
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
                        Text("\(p.code.flagEmoji) \(p.nom)")
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

extension Pays {
    static var defauts: [Pays] {
        [Pays(code: "FR", nom: "France"), Pays(code: "DE", nom: "Allemagne"),
         Pays(code: "IT", nom: "Italie"), Pays(code: "ES", nom: "Espagne"),
         Pays(code: "BE", nom: "Belgique"), Pays(code: "TN", nom: "Tunisie"),
         Pays(code: "DZ", nom: "Algérie"), Pays(code: "MA", nom: "Maroc")]
    }
}
