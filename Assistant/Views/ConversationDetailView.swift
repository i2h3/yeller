import SwiftUI

struct ConversationDetailView: View {

    @Environment(Store.self) private var store
    let conversationId: UInt

    @State private var inputText: String = ""

    private var conversation: Conversation? {
        store.conversations.first { $0.id == conversationId }
    }

    private var messages: [Message] {
        store.messages(for: conversationId)
    }

    private var isTyping: Bool {
        store.typingConversations.contains(conversationId)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            messageList
            Divider()
            inputBar
        }
        .navigationTitle(conversation?.title ?? "")
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }

                    if isTyping {
                        TypingBubbleView()
                            .id("typing")
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isTyping) {
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
            }
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Message Nextcloud Assistant…", text: $inputText, axis: .vertical)
                .lineLimit(1...6)
                .onSubmit {
                    sendMessage()
                }

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(canSend ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Helpers

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendMessage() {
        guard canSend else { return }
        let text = inputText
        inputText = ""
        store.send(text, in: conversationId)
    }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        let targetId: AnyHashable = isTyping ? AnyHashable("typing") : AnyHashable(messages.last?.id ?? 0)
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(targetId, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(targetId, anchor: .bottom)
        }
    }
}

// MARK: - Previews

#Preview {
    let store = Store()
    NavigationStack {
        ConversationDetailView(conversationId: 2)
    }
    .environment(store)
    .frame(width: 600, height: 500)
}
