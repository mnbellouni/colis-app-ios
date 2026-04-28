import SwiftUI

struct ConversationsView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    @State private var vm: ConversationsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if vm?.isLoading == true {
                    ProgressView().tint(.appPrimary)
                } else if vm?.conversations.isEmpty == true {
                    EmptyStateView(
                        icon:    "message",
                        title:   "Aucun message",
                        message: "Vos conversations apparaîtront ici"
                    )
                } else {
                    List(vm?.conversations ?? []) { conv in
                        NavigationLink {
                            ChatView(
                                conversationId: conv.conversationId,
                                autreUserId:    conv.autreUserId
                            )
                        } label: {
                            ConversationRow(conversation: conv)
                        }
                        .listRowBackground(Color.white)
                        .listRowSeparatorTint(Color.appBorder)
                    }
                    .listStyle(.plain)
                    .background(Color.appBackground)
                    .refreshable {
                        await vm?.loadConversations()
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground)
        }
        .task {
            vm = factory.makeConversationsViewModel()
            await vm?.loadConversations()
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.appPrimaryLight)
                    .frame(width: 48, height: 48)
                Text(conversation.autreUserId.prefix(2).uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.autreUserId)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Text(conversation.updatedAt.prefix(10))
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }
                Text(conversation.dernierMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }

            if conversation.nonLus > 0 {
                Text("\(conversation.nonLus)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.appPrimary)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}
