import Foundation
import SwiftData

@Model
final class Thought {
    var id: UUID
    var content: String
    var createdAt: Date

    init(content: String, createdAt: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.createdAt = createdAt
    }
}

// MARK: - Date Helpers
extension Thought {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(createdAt)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(createdAt)
    }

    var dateLabel: String {
        if isToday {
            return "今天"
        } else if isYesterday {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "M月d日"
            return formatter.string(from: createdAt)
        }
    }
}

// MARK: - Grouping
struct ThoughtGroup: Identifiable {
    let id = UUID()
    let dateLabel: String
    let date: Date
    let thoughts: [Thought]
    let isToday: Bool
}

extension Array where Element == Thought {
    func groupedByDate() -> [ThoughtGroup] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: self) { thought -> DateComponents in
            calendar.dateComponents([.year, .month, .day], from: thought.createdAt)
        }

        return grouped.map { (components, thoughts) -> ThoughtGroup in
            let date = calendar.date(from: components) ?? Date()
            let sortedThoughts = thoughts.sorted { $0.createdAt > $1.createdAt }
            let isToday = calendar.isDateInToday(date)

            let dateLabel: String
            if isToday {
                dateLabel = "今天"
            } else if calendar.isDateInYesterday(date) {
                dateLabel = "昨天"
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "zh_CN")
                formatter.dateFormat = "M月d日"
                dateLabel = formatter.string(from: date)
            }

            return ThoughtGroup(dateLabel: dateLabel, date: date, thoughts: sortedThoughts, isToday: isToday)
        }
        .sorted { $0.date > $1.date }
    }
}
