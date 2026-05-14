import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with search field
            VStack(spacing: 12) {
                // Navigation bar
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color.appCanvas)
                            .cornerRadius(12)
                    }

                    // Search field
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17))
                            .foregroundColor(.appTextTertiary)

                        TextField("Ville, pays, mot-clé…", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(.appTextPrimary)
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                performSearch()
                            }

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.appCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSearchFieldFocused ? Color.appPrimary : Color.appBorder, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .padding(.bottom, 12)
            .background(Color.appBackground)

            // Content area
            ScrollView {
                VStack(spacing: 16) {
                    if searchText.isEmpty {
                        // Empty state - suggestions
                        EmptySearchState()
                    } else if isSearching {
                        // Loading state
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        // Search results
                        SearchResultsView(query: searchText)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
            .background(Color.appBackground)
        }
        .navigationBarHidden(true)
        .onAppear {
            isSearchFieldFocused = true
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        // TODO: Implement search API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSearching = false
        }
    }
}

// MARK: - Empty State
struct EmptySearchState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recherches populaires")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appTextPrimary)

            VStack(spacing: 8) {
                SearchSuggestionRow(icon: "mappin.and.ellipse.circle", title: "Paris → Marseille", type: "Route")
                SearchSuggestionRow(icon: "shippingbox.fill", title: "Électronique", type: "Catégorie")
                SearchSuggestionRow(icon: "mappin.and.ellipse.circle", title: "Lyon → Bordeaux", type: "Route")
                SearchSuggestionRow(icon: "shippingbox.fill", title: "Vêtements", type: "Catégorie")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }
}

struct SearchSuggestionRow: View {
    let icon: String
    let title: String
    let type: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.appPrimary)
                .frame(width: 36, height: 36)
                .background(Color.appPrimaryLight)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                Text(type)
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Image(systemName: "arrow.up.left")
                .font(.system(size: 12))
                .foregroundColor(.appTextTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.appCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
}

// MARK: - Search Results
struct SearchResultsView: View {
    let query: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Résultats pour \"\(query)\"")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)

            // TODO: Replace with actual search results
            Text("Aucun résultat pour le moment")
                .font(.system(size: 14))
                .foregroundColor(.appTextTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
        }
    }
}

#Preview {
    SearchView()
}
