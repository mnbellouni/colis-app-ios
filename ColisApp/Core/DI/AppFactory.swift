import SwiftUI

protocol AppFactory {
    func makeLoginViewModel()           -> LoginViewModel
    func makeRegisterViewModel()        -> RegisterViewModel
    func makeHomeViewModel()            -> HomeViewModel
    func makeAnnonceDetailViewModel()    -> AnnonceDetailViewModel
    func makeAnnonceurProfilViewModel()  -> AnnonceurProfilViewModel
    func makeCreateAnnonceViewModel()   -> CreateAnnonceViewModel
    func makeConversationsViewModel()   -> ConversationsViewModel
    func makeChatViewModel()            -> ChatViewModel
    func makeProfileViewModel()         -> ProfileViewModel
    func makeLivraisonViewModel()       -> LivraisonViewModel
    func makeTrajetViewModel()          -> TrajetViewModel
    func makeAnnonceRepository()        -> any AnnonceRepository
    func makeTrackingRepository()       -> any TrackingRepository
    func makeTrajetRepository()         -> any TrajetRepository
    func makeLivraisonRepository()      -> any LivraisonRepository
    func makeFavorisRepository()        -> any FavorisRepository
    func makeAppConfigService()         -> AppConfigService
}

final class ProductionAppFactory: AppFactory {

    private let keychainStorage  = KeychainStorage()
    private let authState: AuthState
    
    init(authState: AuthState) {
            self.authState = authState
    }
    
    var apiClientForRefresh: APIClient { apiClient }

    private lazy var apiClient: APIClient = {
            let client = APIClient(keychainStorage: keychainStorage)
            client.onUnauthorized = { [weak self] in
                Task { @MainActor in
                    self?.authState.logout()
                }
            }
            return client
    }()
    
    private func makeAuthRepository() -> any AuthRepository {
        AuthRepositoryImpl(apiClient: apiClient, keychainStorage: keychainStorage)
    }

    func makeAnnonceRepository() -> any AnnonceRepository {
        AnnonceRepositoryImpl(apiClient: apiClient)
    }

    private func makeMessageRepository() -> any MessageRepository {
        MessageRepositoryImpl(apiClient: apiClient, keychainStorage:keychainStorage)
    }

    private func makeOffreRepository() -> any OffreRepository {
        OffreRepositoryImpl(apiClient: apiClient, keychainStorage: keychainStorage)
    }

    private func makeUserRepository() -> any UserRepository {
        UserRepositoryImpl(apiClient: apiClient)
    }

    private func makeBoostRepository() -> any BoostRepository {
        BoostRepositoryImpl(apiClient: apiClient, keychainStorage: keychainStorage)
    }
    
    func makeTrajetRepository() -> any TrajetRepository {
        TrajetRepositoryImpl(apiClient: apiClient, keychainStorage: keychainStorage)
    }

    func makeLivraisonRepository() -> any LivraisonRepository {
        LivraisonRepositoryImpl(apiClient: apiClient, keychainStorage: keychainStorage)
    }

    func makeFavorisRepository() -> any FavorisRepository {
        FavorisRepositoryImpl(apiClient: apiClient)
    }

    func makeTrackingRepository() -> any TrackingRepository {
        TrackingRepositoryImpl(apiClient: apiClient, keychainStorage: keychainStorage)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(repository: makeAuthRepository(), userRepository: makeUserRepository())
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(repository: makeAuthRepository())
    }

    func makeAppConfigService() -> AppConfigService {
        AppConfigService(apiClient: apiClient)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: makeAnnonceRepository(), favorisRepository: makeFavorisRepository())
    }

    func makeAnnonceDetailViewModel() -> AnnonceDetailViewModel {
        AnnonceDetailViewModel(
            annonceRepository:  makeAnnonceRepository(),
            offreRepository:    makeOffreRepository(),
            favorisRepository:  makeFavorisRepository(),
            userRepository:     makeUserRepository(),
            trajetRepository:   makeTrajetRepository()
        )
    }

    func makeAnnonceurProfilViewModel() -> AnnonceurProfilViewModel {
        AnnonceurProfilViewModel(
            userRepository:    makeUserRepository(),
            annonceRepository: makeAnnonceRepository()
        )
    }

    func makeCreateAnnonceViewModel() -> CreateAnnonceViewModel {
        CreateAnnonceViewModel(
            repository:        makeAnnonceRepository(),
            trajetRepository:  makeTrajetRepository(),
            messageRepository: makeMessageRepository()
        )
    }

    func makeConversationsViewModel() -> ConversationsViewModel {
        ConversationsViewModel(repository: makeMessageRepository())
    }

    func makeChatViewModel() -> ChatViewModel {
        ChatViewModel(repository: makeMessageRepository())
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            userRepository: makeUserRepository(),
            authRepository: makeAuthRepository()
        )
    }

    func makeLivraisonViewModel() -> LivraisonViewModel {
        LivraisonViewModel(livraisonRepository: makeLivraisonRepository())
    }
    
    func makeTrajetViewModel() -> TrajetViewModel {
        TrajetViewModel(repository: makeTrajetRepository())
    }
}
