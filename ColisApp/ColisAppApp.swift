import SwiftUI

@main
struct ColisAppApp: App {

    @StateObject private var authState     = AuthState()
    @StateObject private var configService = AppConfigService(apiClient: APIClient(keychainStorage: KeychainStorage()))

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.factory, ProductionAppFactory(authState: authState))
                .environmentObject(authState)
                .environmentObject(configService)
                .task { await configService.load() }
        }
    }
}
