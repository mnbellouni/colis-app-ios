import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Accueil", systemImage: "house.fill") }

            NavigationStack { TrajetsView() }
                .tabItem { Label("Trajets", systemImage: "map.fill") }

            NavigationStack { SuiviColisView() }
                .tabItem { Label("Envoyer", systemImage: "paperplane.fill") }

            NavigationStack { PrivateView { ConversationsView() } }
                .tabItem { Label("Messages", systemImage: "bubble.left.fill") }

            NavigationStack { PrivateView { ProfileView() } }
                .tabItem { Label("Profil", systemImage: "person.fill") }
        }
        .tint(.appPrimary)
    }
}
