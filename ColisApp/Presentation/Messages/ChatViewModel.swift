import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    private let repository: any MessageRepository

    init(repository: any MessageRepository) {
        self.repository = repository
    }

    @Published var messages:  [Message] = []
    @Published var isLoading  = false
    @Published var isSending  = false
    @Published var error: String? = nil

    private var conversationId = ""
    private var autreUserId    = ""
    var currentUserId          = ""

    func load(conversationId: String, autreUserId: String, currentUserId: String) async {
        self.conversationId = conversationId
        self.autreUserId    = autreUserId
        self.currentUserId  = currentUserId
        isLoading = true
        do {
            messages = try await repository.getConversation(conversationId: conversationId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func sendMessage(contenu: String, annonceId: String = "") async {
        guard !contenu.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSending = true
        do {
            let message = try await repository.sendMessage(
                destinataireId: autreUserId,
                contenu:        contenu,
                annonceId:      annonceId
            )
            messages.append(message)
        } catch {
            self.error = error.localizedDescription
        }
        isSending = false
    }
}
