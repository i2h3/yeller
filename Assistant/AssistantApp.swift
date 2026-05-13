import SwiftUI

@main
struct AssistantApp: App {
    @State private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
