import SwiftUI
import Charts

struct StatsView: View {
    @Bindable var viewModel: ThoughtViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Story Card
                StoryCard(
                    totalDays: viewModel.totalDays,
                    totalThoughts: viewModel.totalThoughts
                )

                // Quick Stats
                QuickStatsRow(
                    thisWeek: viewModel.thisWeekCount,
                    streak: viewModel.streakDays,
                    today: viewModel.todayCount
                )

                // Trend Chart
                TrendChartCard(data: viewModel.last7DaysData())

                // Calendar Heatmap
                CalendarHeatmapCard(viewModel: viewModel)

                // Activity by Time
                ActivityTimeCard(activity: viewModel.activityByTimeOfDay())

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .background(Color.terra50)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.terra300)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("统计")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.ink900)
            }
        }
        .toolbarBackground(Color.terra50.opacity(0.9), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Story Card
struct StoryCard: View {
    let totalDays: Int
    let totalThoughts: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("在过去 ")
                .foregroundColor(.ink400)
            + Text("\(totalDays)")
                .foregroundColor(.terra300)
                .fontWeight(.semibold)
            + Text(" 天里")
                .foregroundColor(.ink400)

            Text("你记录了")
                .foregroundColor(.ink400)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(totalThoughts)")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.terra300, .terra400],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("次灵感")
                    .font(.system(size: 14))
                    .foregroundColor(.ink400)
            }
            .padding(.top, 8)
        }
        .font(.system(size: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.terra300.opacity(0.05), radius: 15, y: 4)
    }
}

// MARK: - Quick Stats Row
struct QuickStatsRow: View {
    let thisWeek: Int
    let streak: Int
    let today: Int

    var body: some View {
        HStack(spacing: 12) {
            StatBox(value: thisWeek, label: "本周")
            StatBox(value: streak, label: "连续天")
            StatBox(value: today, label: "今日")
        }
    }
}

struct StatBox: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.terra300)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.ink400)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.terra300.opacity(0.05), radius: 10, y: 2)
    }
}

// MARK: - Trend Chart Card
struct TrendChartCard: View {
    let data: [(String, Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("近 7 天趋势")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.ink600)

            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    AreaMark(
                        x: .value("Day", item.0),
                        y: .value("Count", item.1)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.terra300.opacity(0.3), Color.terra300.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", item.0),
                        y: .value("Count", item.1)
                    )
                    .foregroundStyle(Color.terra300)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 144)
            .chartYScale(domain: 0...(max(data.map { $0.1 }.max() ?? 1, 1) + 1))
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.ink400)
                        .font(.system(size: 11))
                }
            }
            .clipped()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.terra300.opacity(0.05), radius: 10, y: 2)
    }
}

// MARK: - Calendar Heatmap Card
struct CalendarHeatmapCard: View {
    @Bindable var viewModel: ThoughtViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(currentMonthString)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.ink600)

                Spacer()

                // Legend
                HStack(spacing: 4) {
                    Text("少")
                        .font(.system(size: 10))
                        .foregroundColor(.ink400)
                    ForEach([Color.terra50, Color.terra100, Color.terra200, Color.terra300], id: \.self) { color in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: 12, height: 12)
                    }
                    Text("多")
                        .font(.system(size: 10))
                        .foregroundColor(.ink400)
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10))
                        .foregroundColor(.ink400)
                        .frame(height: 20)
                }
            }

            // Calendar days
            LazyVGrid(columns: columns, spacing: 6) {
                // Empty cells for offset
                ForEach(0..<firstWeekdayOfMonth, id: \.self) { _ in
                    Color.clear
                        .aspectRatio(1, contentMode: .fill)
                }

                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = dateFor(day: day)
                    let count = viewModel.countForDate(date)
                    let isToday = Calendar.current.isDateInToday(date)

                    CalendarDayCell(
                        day: day,
                        count: count,
                        isToday: isToday
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.terra300.opacity(0.05), radius: 10, y: 2)
    }

    private var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月"
        return formatter.string(from: Date())
    }

    private var firstWeekdayOfMonth: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private var daysInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())!
        return range.count
    }

    private func dateFor(day: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
}

struct CalendarDayCell: View {
    let day: Int
    let count: Int
    let isToday: Bool

    private var backgroundColor: Color {
        if count >= 5 { return .terra300 }
        if count >= 3 { return .terra200 }
        if count >= 1 { return .terra100 }
        return .terra50
    }

    private var textColor: Color {
        if count >= 5 { return .white }
        if count >= 3 { return .ink600 }
        return .ink400
    }

    var body: some View {
        Text("\(day)")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isToday ? Color.terra300 : Color.clear, lineWidth: 2)
                    .padding(2)
            )
    }
}

// MARK: - Activity Time Card
struct ActivityTimeCard: View {
    let activity: (morning: Double, afternoon: Double, evening: Double)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("活跃时段")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.ink600)

            VStack(spacing: 16) {
                ActivityRow(label: "上午", percentage: activity.morning)
                ActivityRow(label: "下午", percentage: activity.afternoon)
                ActivityRow(label: "晚上", percentage: activity.evening)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.terra300.opacity(0.05), radius: 10, y: 2)
    }
}

struct ActivityRow: View {
    let label: String
    let percentage: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.ink400)
                .frame(width: 32, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.terra50)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [.terra500, .terra300],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (percentage / 100))
                }
            }
            .frame(height: 10)

            Text("\(Int(percentage))%")
                .font(.system(size: 12))
                .foregroundColor(.ink400)
                .frame(width: 32, alignment: .trailing)
                .monospacedDigit()
        }
    }
}

#Preview {
    NavigationStack {
        StatsView(viewModel: ThoughtViewModel())
    }
}
