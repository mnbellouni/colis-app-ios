import SwiftUI

struct ChatView: View {

    @Environment(\.factory)      private var factory
    @Environment(AuthState.self) private var authState

    let conversationId: String
    let autreUserId:    String

    @State private var vm: ChatViewModel?
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {

            // ── Messages ──────────────────────────────────
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm?.messages ?? []) { message in
                            MessageBubble(
                                message:   message,
                                isFromMe:  message.senderId == authState.userId
                            )
                            .id(message.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: vm?.messages.count ?? 0) { _, _ in
                    if let last = vm?.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // ── Input ─────────────────────────────────────
            HStack(spacing: 12) {
                TextField("Message...", text: $messageText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.appBackground)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )

                Button {
                    let text = messageText
                    messageText = ""
                    Task { await vm?.sendMessage(contenu: text) }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(messageText.isEmpty ? Color.appTextTertiary : Color.appPrimary)
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty || vm?.isSending == true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
        }
        .background(Color.appBackground)
        .navigationTitle(autreUserId)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vm = factory.makeChatViewModel()
            await vm?.load(
                conversationId: conversationId,
                autreUserId:    autreUserId,
                currentUserId:  authState.userId ?? ""
            )
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromMe: Bool

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }

            Text(message.contenu)
                .font(.system(size: 15))
                .foregroundColor(isFromMe ? .white : .appTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isFromMe ? Color.appPrimary : Color.white)
                .cornerRadius(18, corners: isFromMe
                    ? [.topLeft, .topRight, .bottomLeft]
                    : [.topLeft, .topRight, .bottomRight]
                )
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)

            if !isFromMe { Spacer(minLength: 60) }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
