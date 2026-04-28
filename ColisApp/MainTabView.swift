import SwiftUI

enum Tab: Int, CaseIterable {
    case home
    case messages
    case profile

    var title: String {
        switch self {
        case .home:     return "Accueil"
        case .messages: return "Messages"
        case .profile:  return "Profil"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .messages: return "message.fill"
        case .profile:  return "person.fill"
        }
    }
}

struct MainTabView: View {

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(Tab.home.title, systemImage: Tab.home.icon)
            }
            .tag(Tab.home)

            NavigationStack {
                ConversationsView()
            }
            .tabItem {
                Label(Tab.messages.title, systemImage: Tab.messages.icon)
            }
            .tag(Tab.messages)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(Tab.profile.title, systemImage: Tab.profile.icon)
            }
            .tag(Tab.profile)
        }
        .tint(.appPrimary)
    }
}
