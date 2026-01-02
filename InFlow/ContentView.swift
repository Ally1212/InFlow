import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ThoughtViewModel()
    @State private var showStats = false

    var body: some View {
        NavigationStack {
            MainView(viewModel: viewModel, showStats: $showStats)
                .navigationDestination(isPresented: $showStats) {
                    StatsView(viewModel: viewModel)
                }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Thought.self, inMemory: true)
}
