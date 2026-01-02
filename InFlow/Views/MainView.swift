import SwiftUI

struct MainView: View {
    @Bindable var viewModel: ThoughtViewModel
    @Binding var showStats: Bool
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Timeline Content
            TimelineView(viewModel: viewModel)

            // Input Bar
            InputBar(
                text: $inputText,
                isFocused: _isInputFocused,
                onSend: sendThought
            )
        }
        .background(Color.terra50)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("InFlow")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.ink900)
                    .tracking(1)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showStats = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.ink600)
                }
            }
        }
        .toolbarBackground(Color.terra50, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func sendThought() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        viewModel.addThought(content: inputText)
        inputText = ""
        isInputFocused = false
    }
}

#Preview {
    NavigationStack {
        MainView(viewModel: ThoughtViewModel(), showStats: .constant(false))
    }
}
