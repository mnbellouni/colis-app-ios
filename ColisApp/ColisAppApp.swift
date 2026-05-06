import SwiftUI

@main
struct ColisAppApp: App {

    @StateObject private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.factory, ProductionAppFactory(authState: authState))
                .environmentObject(authState)
        }
    }
}
