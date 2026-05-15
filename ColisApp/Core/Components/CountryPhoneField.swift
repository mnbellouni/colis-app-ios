import SwiftUI

struct Country: Identifiable, Hashable {
    let id: String
    let flag: String
    let name: String
    let dialCode: String
    let placeholder: String
    let leadingZero: Bool
}

let supportedCountries: [Country] = [
    Country(id: "DE", flag: "🇩🇪", name: "Allemagne",   dialCode: "+49",  placeholder: "0151 00000000",  leadingZero: true),
    Country(id: "DZ", flag: "🇩🇿", name: "Algérie",     dialCode: "+213", placeholder: "0550 00 00 00",  leadingZero: true),
    Country(id: "BE", flag: "🇧🇪", name: "Belgique",    dialCode: "+32",  placeholder: "0470 00 00 00",  leadingZero: true),
    Country(id: "ES", flag: "🇪🇸", name: "Espagne",     dialCode: "+34",  placeholder: "600 000 000",    leadingZero: false),
    Country(id: "FR", flag: "🇫🇷", name: "France",      dialCode: "+33",  placeholder: "06 00 00 00 00", leadingZero: true),
    Country(id: "IT", flag: "🇮🇹", name: "Italie",      dialCode: "+39",  placeholder: "320 000 0000",   leadingZero: false),
    Country(id: "MA", flag: "🇲🇦", name: "Maroc",       dialCode: "+212", placeholder: "0600 000000",    leadingZero: true),
    Country(id: "NL", flag: "🇳🇱", name: "Pays-Bas",    dialCode: "+31",  placeholder: "06 00000000",    leadingZero: true),
    Country(id: "PT", flag: "🇵🇹", name: "Portugal",    dialCode: "+351", placeholder: "912 000 000",    leadingZero: false),
    Country(id: "GB", flag: "🇬🇧", name: "Royaume-Uni", dialCode: "+44",  placeholder: "07700 000000",   leadingZero: true),
    Country(id: "CH", flag: "🇨🇭", name: "Suisse",      dialCode: "+41",  placeholder: "079 000 00 00",  leadingZero: true),
    Country(id: "TN", flag: "🇹🇳", name: "Tunisie",     dialCode: "+216", placeholder: "20 000 000",     leadingZero: false),
]

func defaultCountry() -> Country {
    let regionCode = Locale.current.region?.identifier ?? "FR"
    return supportedCountries.first { $0.id == regionCode }
        ?? supportedCountries.first { $0.id == "FR" }!
}

struct CountryPhoneField: View {
    @Binding var localNumber: String
    @Binding var selectedCountry: Country
    var errorMessage: String? = nil
    var onBlur: (() -> Void)? = nil

    @State  private var showPicker = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Téléphone")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextSecondary)

            HStack(spacing: 0) {
                Button { showPicker = true } label: {
                    HStack(spacing: 6) {
                        Text(selectedCountry.flag).font(.system(size: 18))
                        Text(selectedCountry.dialCode)
                            .font(.system(size: 15))
                            .foregroundColor(.appTextPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                }

                Rectangle()
                    .fill(Color.appBorder)
                    .frame(width: 1, height: 24)

                TextField(selectedCountry.placeholder, text: $localNumber)
                    .keyboardType(.phonePad)
                    .font(.system(size: 15))
                    .foregroundColor(.appTextPrimary)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .focused($focused)
                    .onChange(of: focused) { _, isFocused in
                        if !isFocused { onBlur?() }
                    }
            }
            .background(Color.appCanvas)
            .cornerRadius(AppRadius.input)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.input)
                    .stroke(borderColor, lineWidth: 1.5)
            )

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.appError)
            }
        }
        .sheet(isPresented: $showPicker) {
            CountryPickerSheet(selected: $selectedCountry)
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return .appError }
        if focused { return .appPrimary }
        return .appBorder
    }
}

private struct CountryPickerSheet: View {
    @Binding var selected: Country
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var filtered: [Country] {
        search.isEmpty ? supportedCountries
            : supportedCountries.filter {
                $0.name.localizedCaseInsensitiveContains(search) ||
                $0.dialCode.contains(search)
            }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { country in
                Button {
                    selected = country
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(country.flag).font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name).foregroundColor(.appTextPrimary)
                            Text(country.dialCode)
                                .font(.system(size: 13))
                                .foregroundColor(.appTextSecondary)
                        }
                        Spacer()
                        if country.id == selected.id {
                            Image(systemName: "checkmark").foregroundColor(.appPrimary)
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Rechercher un pays")
            .navigationTitle("Choisir un pays")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }
}
