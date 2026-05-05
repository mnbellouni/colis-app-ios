import Foundation
import Observation

@Observable
@MainActor
final class ConversationsViewModel {

    private let repository: any MessageRepository

    init(repository: any MessageRepository) {
        self.repository = repository
    }

    var conversations: [Conversation] = []
    var isLoading      = false
    var error: String? = nil

    func loadConversations() async {
        isLoading = true
        error     = nil
        do {
            conversations = try await repository.getConversations()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
