import SwiftUI

struct MessageBubbleView: View {

    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser {
                Spacer(minLength: 56)
            } else {
                AssistantAvatar(size: 28)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if !isUser {
                    Text("Nextcloud Assistant")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }

                Text(message.content)
                    .textSelection(.enabled)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(isUser ? Color.accentColor : Color.primary.opacity(0.08))
                    .foregroundStyle(isUser ? Color.white : Color.primary)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: isUser ? 18 : 4,
                            bottomTrailingRadius: isUser ? 4 : 18,
                            topTrailingRadius: 18
                        )
                    )
            }

            if !isUser {
                Spacer(minLength: 56)
            }
        }
    }
}

// MARK: - Typing indicator

struct TypingBubbleView: View {

    @State private var phase: Int = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            AssistantAvatar(size: 28)

            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.primary.opacity(0.4))
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.4 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.primary.opacity(0.08))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 4,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
            )

            Spacer(minLength: 56)
        }
        .onAppear { phase = 0 }
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 12) {
        MessageBubbleView(message: Message(content: "Hey, what's the best way to learn SwiftUI?", id: 1, role: .user, sessionId: 1))
        MessageBubbleView(message: Message(content: "Start with Apple's official tutorials, then build small personal projects. Reading other people's code on GitHub helps a lot once you have the basics.", id: 2, role: .assistant, sessionId: 1))
        TypingBubbleView()
    }
    .padding()
}
