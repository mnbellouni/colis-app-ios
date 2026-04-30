import SwiftUI

enum Tab: Int, CaseIterable {
    case home
    case trajets
    case messages
    case profile

    var title: String {
        switch self {
        case .home:     return "Accueil"
        case .trajets:  return "Trajets"
        case .messages: return "Messages"
        case .profile:  return "Profil"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .trajets:  return "airplane"
        case .messages: return "message.fill"
        case .profile:  return "person.fill"
        }
    }
}

struct MainTabView: View {

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            // ── Accueil (annonces) ────────────────────────
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Accueil", systemImage: "house.fill")
            }
            .tag(Tab.home)

            // ── Trajets (voyageurs) ───────────────────────
            NavigationStack {
                TrajetsView()
            }
            .tabItem {
                Label("Trajets", systemImage: "airplane")
            }
            .tag(Tab.trajets)

            // ── Messages (privé) ──────────────────────────
            NavigationStack {
                PrivateView {
                    ConversationsView()
                }
            }
            .tabItem {
                Label("Messages", systemImage: "message.fill")
            }
            .tag(Tab.messages)

            // ── Profil (privé) ────────────────────────────
            NavigationStack {
                PrivateView {
                    ProfileView()
                }
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(Tab.profile)
        }
        .tint(.appPrimary)
    }
}
