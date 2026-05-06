import SwiftUI

struct ConversationsView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    @StateObject private var vmHolder = VMHolder<ConversationsViewModel>()
    private var vm: ConversationsViewModel? { vmHolder.vm }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Header ────────────────────────────────
                VStack(alignment: .leading, spacing: 2) {
                    Text("Messages")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    if let count = vm?.conversations.filter({ $0.nonLus > 0 }).count, count > 0 {
                        Text("\(count) nouvelle\(count > 1 ? "s" : "") conversation\(count > 1 ? "s" : "")")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color.appBackground)

                // ── Contenu ───────────────────────────────
                Group {
                    if vm?.isLoading == true {
                        Spacer()
                        ProgressView().tint(.appPrimary)
                        Spacer()
                    } else if vm?.conversations.isEmpty == true {
                        Spacer()
                        EmptyStateView(
                            icon:    "bubble.left.and.bubble.right",
                            title:   "Aucun message",
                            message: "Vos conversations apparaîtront ici"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(vm?.conversations ?? []) { conv in
                                    NavigationLink {
                                        ChatView(conversationId: conv.conversationId, autreUserId: conv.autreUserId)
                                    } label: {
                                        ConversationRow(conversation: conv)
                                    }
                                    .buttonStyle(.plain)

                                    if conv.id != vm?.conversations.last?.id {
                                        Divider()
                                            .padding(.leading, 78)
                                            .padding(.horizontal, 18)
                                    }
                                }
                            }
                            .background(Color.appCard)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appBorder, lineWidth: 1))
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                        }
                        .background(Color.appBackground)
                        .refreshable { await vm?.loadConversations() }
                    }
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
        }
        .task {
            vmHolder.vm = factory.makeConversationsViewModel()
            await vm?.loadConversations()
        }
    }
}

// ── Ligne conversation ────────────────────────────────────
struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(seed: conversation.autreUserId, size: 48, showOnline: true)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.autreUserId.prefix(12))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(formattedTime(conversation.updatedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.appTextTertiary)
                }

                Text(conversation.dernierMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)

                // Chip annonce
                if !conversation.annonceId.isEmpty {
                    Text(String(conversation.annonceId.prefix(16)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.appPrimaryLight)
                        .cornerRadius(99)
                }
            }

            if conversation.nonLus > 0 {
                Text("\(conversation.nonLus)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Color.appError)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func formattedTime(_ iso: String) -> String {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else {
            return String(iso.prefix(10))
        }
        let diff = now.timeIntervalSince(date)
        if diff < 86400 {
            let h = Calendar.current.component(.hour, from: date)
            let m = Calendar.current.component(.minute, from: date)
            return String(format: "%02d:%02d", h, m)
        } else if diff < 172800 {
            return "Hier"
        } else {
            let days = ["Dim","Lun","Mar","Mer","Jeu","Ven","Sam"]
            let weekday = Calendar.current.component(.weekday, from: date) - 1
            return days[safe: weekday] ?? String(iso.prefix(10))
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
