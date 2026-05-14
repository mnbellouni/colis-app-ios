import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView(selectedTab: $selectedTab) }
                .tabItem { Label("Accueil", systemImage: "house.fill") }
                .tag(0)

            NavigationStack { PrivateView { ConversationsView() } }
                .tabItem { Label("Messages", systemImage: "bubble.left.fill") }
                .tag(1)

            NavigationStack { SuiviTabView() }
                .tabItem { Label("Suivi", systemImage: "shippingbox.fill") }
                .tag(2)

            NavigationStack { PrivateView { ProfileView() } }
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(.appPrimary)
    }
}
