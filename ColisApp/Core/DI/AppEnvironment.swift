import SwiftUI

// IMPORTANT : toujours injecter factory ET authState ensemble depuis ColisAppApp (ou les Previews).
// Le defaultValue crée un AuthState indépendant — sans injection explicite, factory.onUnauthorized
// et l'EnvironmentObject authState ne partagent pas le même état.
private struct AppFactoryKey: EnvironmentKey {
    @MainActor
    static let defaultValue: any AppFactory = ProductionAppFactory(
        authState: AuthState()
    )
}

extension EnvironmentValues {
    var factory: any AppFactory {
        get { self[AppFactoryKey.self] }
        set { self[AppFactoryKey.self] = newValue }
    }
}
