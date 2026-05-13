import SwiftUI

struct ConversationListView: View {

    @Environment(Store.self) private var store
    @Binding var selectedId: Conversation.ID?

    var body: some View {
        List(store.conversations, selection: $selectedId) { conversation in
            ConversationRowView(
                conversation: conversation,
                lastMessage: store.lastMessage(for: conversation.id)
            )
            .tag(conversation.id)
        }
        .listStyle(.sidebar)
        .navigationTitle("Conversations")
    }
}

// MARK: - Row

private struct ConversationRowView: View {

    let conversation: Conversation
    let lastMessage: Message?

    var body: some View {
        HStack(spacing: 12) {
            AssistantAvatar(size: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(conversation.title)
                    .font(.headline)
                    .lineLimit(1)

                if let msg = lastMessage {
                    HStack(spacing: 4) {
                        if msg.role == .user {
                            Text("You:")
                                .foregroundStyle(.secondary)
                        }
                        Text(msg.content)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Previews

#Preview {
    let store = Store()
    NavigationSplitView {
        ConversationListView(selectedId: .constant(store.conversations.first?.id))
    } detail: {
        Text("Detail")
    }
    .environment(store)
}
