import Foundation

protocol MessageRepository {
    func getConversations() async throws -> [Conversation]
    func getConversation(conversationId: String) async throws -> [Message]
    func sendMessage(destinataireId: String, contenu: String, annonceId: String) async throws -> Message
}
