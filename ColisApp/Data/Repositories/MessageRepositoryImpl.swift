import Foundation

class MessageRepositoryImpl: MessageRepository {

    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage

    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }

    func getConversations() async throws -> [Conversation] {
        let userId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.get(url: "\(APIEndpoints.messages)?userId=\(userId)")
    }

    func getConversation(conversationId: String) async throws -> [Message] {
        return try await apiClient.get(url: APIEndpoints.conversation(id: conversationId))
    }

    func sendMessage(
        destinataireId: String,
        contenu: String,
        annonceId: String = ""
    ) async throws -> Message {
        let senderId = keychainStorage.get(forKey: KeychainStorage.Keys.userId) ?? ""
        return try await apiClient.post(
            url: APIEndpoints.messages,
            body: [
                "senderId":       senderId,
                "destinataireId": destinataireId,
                "contenu":        contenu,
                "annonceId":      annonceId
            ]
        )
    }
}
