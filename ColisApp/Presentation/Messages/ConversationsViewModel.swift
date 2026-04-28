import Foundation
import Combine

@MainActor
final class ConversationsViewModel: ObservableObject {

    private let repository: any MessageRepository

    init(repository: any MessageRepository) {
        self.repository = repository
    }

    @Published var conversations: [Conversation] = []
    @Published var isLoading      = false
    @Published var error: String? = nil

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
