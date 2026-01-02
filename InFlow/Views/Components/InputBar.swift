import SwiftUI

struct InputBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Text Input
            TextField("记录此刻的想法...", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .font(.system(size: 15))
                .foregroundColor(.ink900)
                .tint(.terra300)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.terra300.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit(onSend)

            // Send Button
            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.terra200 : Color.terra300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .overlay(
            Rectangle()
                .fill(Color.terra300.opacity(0.1))
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    VStack {
        Spacer()
        InputBar(text: .constant(""), onSend: {})
    }
    .background(Color.terra50)
}
