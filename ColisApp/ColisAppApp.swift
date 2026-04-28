import SwiftUI

@main
struct ColisAppApp: App {

    @State private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.factory, ProductionAppFactory())
                .environment(authState)
        }
    }
}
