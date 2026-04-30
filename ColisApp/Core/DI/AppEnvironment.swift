import SwiftUI

private struct AppFactoryKey: EnvironmentKey {
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
