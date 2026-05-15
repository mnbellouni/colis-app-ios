import Foundation
import Combine

final class AppConfigService: ObservableObject {

    @Published private(set) var config: RemoteConfig = .vide

    private let apiClient: APIClient
    private static let cacheKey = "app_config_cache"

    init(apiClient: APIClient) {
        self.apiClient = apiClient
        self.config = Self.loadCache() ?? .vide
    }

    @MainActor
    func load() async {
        do {
            let fetched: RemoteConfig = try await apiClient.get(url: APIEndpoints.config, requiresAuth: false)
            config = fetched
            Self.saveCache(fetched)
        } catch {
            // Utilise le cache existant — aucune action requise
        }
    }

    // ── Cache UserDefaults ─────────────────────────────────
    private static func saveCache(_ config: RemoteConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    private static func loadCache() -> RemoteConfig? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(RemoteConfig.self, from: data)
    }
}
