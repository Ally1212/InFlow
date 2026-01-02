import Foundation
import SwiftData
import SwiftUI

@Observable
final class ThoughtViewModel {
    private var modelContext: ModelContext?

    var thoughts: [Thought] = []

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchThoughts()
    }

    func fetchThoughts() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Thought>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            thoughts = try modelContext.fetch(descriptor)
        } catch {
            debugPrint("Failed to fetch thoughts: \(error)")
        }
    }

    func addThought(content: String) {
        guard let modelContext, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let thought = Thought(content: content.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(thought)

        do {
            try modelContext.save()
            fetchThoughts()
        } catch {
            debugPrint("Failed to save thought: \(error)")
        }
    }

    func deleteThought(_ thought: Thought) {
        guard let modelContext else { return }

        modelContext.delete(thought)

        do {
            try modelContext.save()
            fetchThoughts()
        } catch {
            debugPrint("Failed to delete thought: \(error)")
        }
    }

    var groupedThoughts: [ThoughtGroup] {
        thoughts.groupedByDate()
    }

    // MARK: - Statistics

    var totalThoughts: Int {
        thoughts.count
    }

    var totalDays: Int {
        guard let earliest = thoughts.min(by: { $0.createdAt < $1.createdAt })?.createdAt else {
            return 0
        }
        let days = Calendar.current.dateComponents([.day], from: earliest, to: Date()).day ?? 0
        return max(days, 1)
    }

    var thisWeekCount: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return thoughts.filter { $0.createdAt >= startOfWeek }.count
    }

    var todayCount: Int {
        thoughts.filter { Calendar.current.isDateInToday($0.createdAt) }.count
    }

    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        while true {
            let hasThought = thoughts.contains { thought in
                calendar.isDate(thought.createdAt, inSameDayAs: checkDate)
            }

            if hasThought {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        return streak
    }

    func countForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        return thoughts.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
    }

    func last7DaysData() -> [(String, Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            formatter.dateFormat = "E"
            let dayName = formatter.string(from: date)
            let count = countForDate(date)
            return (dayName, count)
        }
    }

    func activityByTimeOfDay() -> (morning: Double, afternoon: Double, evening: Double) {
        guard !thoughts.isEmpty else { return (0, 0, 0) }

        let calendar = Calendar.current
        var morning = 0
        var afternoon = 0
        var evening = 0

        for thought in thoughts {
            let hour = calendar.component(.hour, from: thought.createdAt)
            if hour >= 6 && hour < 12 {
                morning += 1
            } else if hour >= 12 && hour < 18 {
                afternoon += 1
            } else {
                evening += 1
            }
        }

        let total = Double(thoughts.count)
        return (
            morning: Double(morning) / total * 100,
            afternoon: Double(afternoon) / total * 100,
            evening: Double(evening) / total * 100
        )
    }
}
