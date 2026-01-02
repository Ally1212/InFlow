import SwiftUI
import SwiftData

@main
struct InFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Thought.self)
    }
}
