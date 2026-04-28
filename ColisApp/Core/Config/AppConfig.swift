import Foundation

enum AppEnvironment {
    case dev
    case staging
    case prod
}

struct AppConfig {

    static let current: AppEnvironment = .dev

    static var baseURL: String {
        switch current {
        case .dev:
            return "https://yckhsi7nbi.execute-api.eu-west-3.amazonaws.com/prod"
        case .staging:
            return "https://s8cb4bxtch.execute-api.eu-west-3.amazonaws.com/prod"
        case .prod:
            return "https://PROD_URL.execute-api.eu-west-3.amazonaws.com/prod"
        }
    }

    static var isDebug: Bool {
        return current != .prod
    }
}
