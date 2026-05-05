import SwiftUI

struct RootView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    var body: some View {
        MainTabView()
            .task {
                if let f = factory as? ProductionAppFactory {
                    await authState.refreshTokenIfNeeded(apiClient: f.apiClientForRefresh)
                }
            }
    }
}
