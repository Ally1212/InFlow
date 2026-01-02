import SwiftUI

struct TimelineView: View {
    @Bindable var viewModel: ThoughtViewModel

    var body: some View {
        if viewModel.thoughts.isEmpty {
            // 空状态居中显示
            EmptyStateView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // 有数据时显示时间轴
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.groupedThoughts) { group in
                        TimelineSection(group: group, onDelete: viewModel.deleteThought)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(
                // 时间轴线
                GeometryReader { _ in
                    Rectangle()
                        .fill(Color.terra200.opacity(0.4))
                        .frame(width: 1)
                        .padding(.leading, 22)
                }
            )
        }
    }
}

// MARK: - Timeline Section
struct TimelineSection: View {
    let group: ThoughtGroup
    let onDelete: (Thought) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date Header with Dot
            HStack(spacing: 12) {
                TimeDot(isToday: group.isToday)
                Text(group.dateLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.ink600)
                    .tracking(0.5)
            }

            // Thought Cards
            VStack(spacing: 12) {
                ForEach(group.thoughts, id: \.id) { thought in
                    ThoughtCard(thought: thought)
                        .contextMenu {
                            Button(role: .destructive) {
                                onDelete(thought)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.leading, 32)
        }
    }
}

// MARK: - Time Dot
struct TimeDot: View {
    let isToday: Bool

    var body: some View {
        Circle()
            .fill(Color.terra300)
            .frame(width: isToday ? 10 : 8, height: isToday ? 10 : 8)
            .background(
                Circle()
                    .stroke(Color.terra300.opacity(0.12), lineWidth: isToday ? 3 : 0)
                    .frame(width: 16, height: 16)
            )
    }
}

// MARK: - Thought Card
struct ThoughtCard: View {
    let thought: Thought
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(thought.content)
                .font(.system(size: 15))
                .foregroundColor(.ink900)
                .lineSpacing(6)
                .tracking(0.3)

            Text(thought.timeString)
                .font(.system(size: 11))
                .foregroundColor(.ink400)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.terra300.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color(hex: "B4785A").opacity(0.03), radius: 1, y: 1)
        .shadow(color: Color(hex: "B4785A").opacity(0.04), radius: 12, y: 4)
        .scaleEffect(isPressed ? 0.985 : 1)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb")
                .font(.system(size: 48))
                .foregroundColor(.terra200)

            Text("记录你的第一个想法")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.ink400)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TimelineView(viewModel: ThoughtViewModel())
}
