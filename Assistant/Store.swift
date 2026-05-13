import Foundation
import Observation

@Observable
class Store {

    // MARK: - State

    var conversations: [Conversation] = []

    ///
    /// Convenience getter to check for required credentials to be available.
    ///
    var hasCredentials: Bool {
        name != nil && password != nil && server != nil
    }

    var messagesByConversation: [UInt: [Message]] = [:]

    ///
    /// The user name to log in with.
    ///
    var name: String?

    ///
    /// The user password to authenticate with.
    ///
    var password: String?

    ///
    /// The server address to log in at.
    ///
    var server: URL?

    var typingConversations: Set<UInt> = []

    private var nextMessageId: UInt = 1_000

    // MARK: - Init

    init() {
        seedMockData()
    }

    // MARK: - Queries

    func messages(for conversationId: UInt) -> [Message] {
        messagesByConversation[conversationId] ?? []
    }

    func lastMessage(for conversationId: UInt) -> Message? {
        messagesByConversation[conversationId]?.last
    }

    // MARK: - Actions

    func send(_ content: String, in conversationId: UInt) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        append(Message(content: trimmed, id: nextId(), role: .user, sessionId: conversationId),
               to: conversationId)

        typingConversations.insert(conversationId)

        Task {
            try? await Task.sleep(for: .seconds(Double.random(in: 1.0...2.0)))
            typingConversations.remove(conversationId)
            append(Message(content: mockReply(for: trimmed), id: nextId(), role: .assistant, sessionId: conversationId),
                   to: conversationId)
        }
    }

    // MARK: - Helpers

    private func append(_ message: Message, to conversationId: UInt) {
        messagesByConversation[conversationId, default: []].append(message)
    }

    private func nextId() -> UInt {
        defer { nextMessageId += 1 }
        return nextMessageId
    }

    private func mockReply(for input: String) -> String {
        let replies = [
            "That's a great point! Let me think about it and get back to you with some ideas.",
            "Interesting question. Based on what I know, I'd recommend exploring a few different approaches.",
            "Sure! Here's a helpful overview: the key thing to keep in mind is context and clarity.",
            "Happy to help with that. Could you give me a bit more detail so I can tailor my answer?",
            "Absolutely. This is a well-known topic — let me break it down step by step.",
            "Great question! The short answer is yes, but there are some nuances worth considering.",
        ]
        return replies.randomElement()!
    }

    // MARK: - Mock Data

    private func seedMockData() {
        conversations = [
            Conversation(id: 1, title: "Trip Planning"),
            Conversation(id: 2, title: "Swift Development"),
            Conversation(id: 3, title: "Recipe Suggestions"),
            Conversation(id: 4, title: "Book Recommendations"),
            Conversation(id: 5, title: "Workout Routine"),
        ]

        var mid: UInt = 1

        // Conversation 1 — Trip Planning
        messagesByConversation[1] = [
            m(mid,   1, .user,      "I'm planning a trip to Japan next month. Any suggestions on where to go?"),
            m(mid+1, 1, .assistant, "Japan is a wonderful choice! I'd suggest starting with a few days in Tokyo to soak in the city energy, then head to Kyoto for temples and traditional culture. Osaka is a must for food lovers, and a day trip to Nara to see the deer is unforgettable."),
            m(mid+2, 1, .user,      "I'm going in mid-April — will cherry blossoms still be around?"),
            m(mid+3, 1, .assistant, "You're in luck! Cherry blossom season peaks in late March to early April in Tokyo and Kyoto, but in mid-April you can often still find late-blooming sakura, especially at higher elevations. Parks like Shinjuku Gyoen and Maruyama Park are beautiful spots to look for."),
            m(mid+4, 1, .user,      "Perfect. How many days total would you recommend?"),
            m(mid+5, 1, .assistant, "For a comfortable pace I'd plan 12–14 days: 3–4 in Tokyo, 3 in Kyoto, 2 in Osaka, 1 day trip to Nara, and a couple of flex days for spontaneous detours. That way you're never rushed."),
        ]
        mid += 6

        // Conversation 2 — Swift Development
        messagesByConversation[2] = [
            m(mid,   2, .user,      "What's the difference between @State and @Observable in SwiftUI?"),
            m(mid+1, 2, .assistant, "@State is a property wrapper for local, view-owned value types — it tells SwiftUI to re-render the view when the value changes. @Observable (introduced in Swift 5.9 / iOS 17) is a macro you apply to a class to make all its stored properties automatically observable, so SwiftUI views re-render when any property they read changes. Think of @Observable as the modern replacement for ObservableObject."),
            m(mid+2, 2, .user,      "So I should prefer @Observable over ObservableObject for new code?"),
            m(mid+3, 2, .assistant, "Yes, for iOS 17+ / macOS 14+ targets, @Observable is the recommended approach. It removes the need for @Published, is more granular (only views that read a specific property update), and requires less boilerplate. ObservableObject is still valid for older deployment targets or Combine-heavy architectures."),
            m(mid+4, 2, .user,      "How do I pass an @Observable object through the environment?"),
            m(mid+5, 2, .assistant, "It's straightforward: inject with `.environment(myObject)` on a parent view, then read it in a child with `@Environment(MyType.self) private var myObject`. No EnvironmentKey needed — the type itself serves as the key."),
            m(mid+6, 2, .user,      "That's much cleaner than the old way. Thanks!"),
            m(mid+7, 2, .assistant, "Agreed, it's a big quality-of-life improvement. Enjoy building with it!"),
        ]
        mid += 8

        // Conversation 3 — Recipe Suggestions
        messagesByConversation[3] = [
            m(mid,   3, .user,      "I have chicken, lemon, garlic, and some fresh herbs. What can I make?"),
            m(mid+1, 3, .assistant, "Classic lemon-herb roasted chicken! Rub the chicken with minced garlic, olive oil, lemon zest, chopped rosemary or thyme, salt, and pepper. Roast at 200 °C for about 45 minutes (for a whole bird) or 25 minutes for thighs. Squeeze fresh lemon juice over it right before serving."),
            m(mid+2, 3, .user,      "I only have boneless breasts. Does that change things?"),
            m(mid+3, 3, .assistant, "Slightly — boneless breasts cook faster and can dry out easily. Pound them to an even thickness, sear in an oven-safe pan with oil over high heat for 2–3 minutes per side, then finish in the oven at 200 °C for 10–12 minutes. Rest for 5 minutes before slicing. The lemon-garlic sauce is great deglazed right in the pan."),
            m(mid+4, 3, .user,      "Any good sides to go with it?"),
            m(mid+5, 3, .assistant, "Roasted cherry tomatoes, a simple arugula salad with shaved Parmesan, or garlicky sautéed green beans all pair beautifully. If you want something heartier, orzo tossed with olive oil and lemon is a natural match."),
        ]
        mid += 6

        // Conversation 4 — Book Recommendations
        messagesByConversation[4] = [
            m(mid,   4, .user,      "Can you recommend some good sci-fi novels? I loved Dune and The Martian."),
            m(mid+1, 4, .assistant, "Great taste! Given those two, you'd likely enjoy:\n• **Project Hail Mary** by Andy Weir — same problem-solving tone as The Martian, but even more inventive.\n• **A Fire Upon the Deep** by Vernor Vinge — epic space opera with fascinating alien civilisations.\n• **Children of Time** by Adrian Tchaikovsky — explores the evolution of non-human intelligence across millennia.\n• **Hyperion** by Dan Simmons — rich, literary sci-fi with a Canterbury Tales structure."),
            m(mid+2, 4, .user,      "I've heard a lot about Project Hail Mary. Is it a standalone?"),
            m(mid+3, 4, .assistant, "Yes, it's completely standalone — no series commitment needed. It starts slow as the protagonist wakes up with amnesia, but once the mystery unravels it becomes almost impossible to put down. The science is accurate and approachable, much like The Martian."),
            m(mid+4, 4, .user,      "Perfect, that's going on my list. Any non-fiction science books you'd recommend?"),
            m(mid+5, 4, .assistant, "Absolutely. Some classics worth your time:\n• **The Feynman Lectures on Physics** — brilliant if you want deep insight into how physics works.\n• **A Brief History of Time** by Stephen Hawking — elegant and accessible.\n• **The Gene** by Siddhartha Mukherjee — a sweeping history of genetics, beautifully written.\n• **Surely You're Joking, Mr. Feynman!** — more memoir than textbook, but endlessly entertaining."),
        ]
        mid += 6

        // Conversation 5 — Workout Routine
        messagesByConversation[5] = [
            m(mid,   5, .user,      "I want to start working out at home. I have no equipment. Where do I begin?"),
            m(mid+1, 5, .assistant, "Bodyweight training is a fantastic start and requires zero equipment. A solid beginner routine 3 days a week could look like: Push-ups (3×10), Squats (3×15), Lunges (3×10 each leg), Plank (3×30 s), and Mountain climbers (3×20). Rest 60 seconds between sets. Focus on form before reps."),
            m(mid+2, 5, .user,      "How long before I start seeing results?"),
            m(mid+3, 5, .assistant, "With consistent effort and decent nutrition, most people notice improved strength and endurance within 2–3 weeks, and visible changes in body composition around 4–8 weeks. Sleep and diet accelerate or slow this considerably — protein intake and recovery days matter as much as the workouts themselves."),
            m(mid+4, 5, .user,      "Should I do cardio as well?"),
            m(mid+5, 5, .assistant, "It depends on your goals. For general fitness, adding 20–30 minutes of moderate cardio (brisk walking, jogging, jump rope) 2–3 times a week is beneficial. If fat loss is the priority, cardio helps create a caloric deficit. If you're primarily after strength, prioritise the resistance training and keep cardio light so you recover well."),
            m(mid+6, 5, .user,      "This is really helpful, thank you!"),
            m(mid+7, 5, .assistant, "Happy to help! Consistency is the real secret — even two solid sessions a week beats a perfect plan you never follow. Good luck!"),
        ]
    }

    private func m(_ id: UInt, _ sessionId: UInt, _ role: Role, _ content: String) -> Message {
        Message(content: content, id: id, role: role, sessionId: sessionId)
    }
}
