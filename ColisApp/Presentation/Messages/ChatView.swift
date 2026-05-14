import SwiftUI

struct ChatView: View {

    @Environment(\.factory)        private var factory
    @EnvironmentObject private var authState: AuthState

    let conversationId: String
    let autreUserId:    String
    var annonceId:      String? = nil
    var isTransporter:  Bool    = false

    @StateObject private var vmHolder = VMHolder<ChatViewModel>()
    private var vm: ChatViewModel? { vmHolder.vm }

    @State private var messageText      = ""
    @State private var codeCTADismissed = false

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
                .onChange(of: vm?.messages.count ?? 0) {
                    if let last = vm?.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // ── CTA code livraison ────────────────────────
            if vm?.shouldShowCodeCTA == true && !codeCTADismissed {
                CodeLivraisonCTABanner(onDismiss: { codeCTADismissed = true })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
            .background(Color.appCard)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
        }
        .background(Color.appBackground)
        .navigationTitle(autreUserId)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .task {
            vmHolder.vm = factory.makeChatViewModel()
            await vm?.load(
                conversationId: conversationId,
                autreUserId:    autreUserId,
                currentUserId:  authState.userId ?? "",
                annonceId:      annonceId,
                isTransporter:  isTransporter
            )
        }
    }
}

// ── CTA bannière code livraison ───────────────────────────
struct CodeLivraisonCTABanner: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 20))
                .foregroundColor(.appPrimary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Prendre en charge ce colis ?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                Text("Générez votre code livraison pour confirmer la remise et recevoir les infos de livraison.")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    // TODO: appeler POST /transactions/:id/code-livraison/generer
                } label: {
                    Text("Générer mon code")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.appPrimary)
                        .cornerRadius(99)
                }
                .padding(.top, 2)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appTextTertiary)
            }
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
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
