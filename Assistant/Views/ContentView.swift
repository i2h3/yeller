import SwiftUI

struct ContentView: View {

    @Environment(Store.self) private var store
    @State private var selectedId: Conversation.ID?

    var body: some View {
        if store.hasCredentials {
            NavigationSplitView {
                ConversationListView(selectedId: $selectedId)
                    .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
            } detail: {
                if let id = selectedId {
                    ConversationDetailView(conversationId: id)
                } else {
                    ContentUnavailableView(
                        "No Conversation Selected",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Choose a conversation from the sidebar.")
                    )
                }
            }
            .navigationSplitViewStyle(.balanced)
            .onAppear {
                if selectedId == nil {
                    selectedId = store.conversations.first?.id
                }
            }
        } else {
            ServerAddressView()
        }
    }
}

#Preview {
    ContentView()
        .environment(Store())
        .frame(width: 900, height: 600)
}
