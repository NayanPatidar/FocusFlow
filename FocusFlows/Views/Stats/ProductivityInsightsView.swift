import SwiftUI

struct ProductivityInsightsView: View {
    let tasks: [FocusTask]
    let habits: [Habit]

    private var completedTasksThisWeek: Int {
        tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return Calendar.current.isDate(completedAt, equalTo: .now, toGranularity: .weekOfYear)
        }.count
    }

    private var tasksCreatedThisWeek: Int {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDate(dueDate, equalTo: .now, toGranularity: .weekOfYear)
        }.count
    }

    private var activeDaysThisWeek: Int {
        let calendar = Calendar.current

        return (0..<7).filter { offset in
            guard let day = calendar.date(
                byAdding: .day,
                value: -6 + offset,
                to: calendar.startOfDay(for: .now)
            ) else { return false }

            return tasks.contains { task in
                guard let completedAt = task.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: day)
            }
        }.count
    }

    private var mostProductiveDay: String {
        let calendar = Calendar.current

        let dailyCounts = (0..<7).compactMap { offset -> (Date, Int)? in
            guard let day = calendar.date(
                byAdding: .day,
                value: -6 + offset,
                to: calendar.startOfDay(for: .now)
            ) else { return nil }

            let count = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: day)
            }.count

            return (day, count)
        }

        guard let bestDay = dailyCounts.max(by: { $0.1 < $1.1 }),
              bestDay.1 > 0 else {
            return "No activity yet"
        }

        return bestDay.0.formatted(.dateTime.weekday(.wide))
    }

    private var totalCurrentStreak: Int {
        habits.reduce(0) {
            $0 + HabitStreakCalculator.currentStreak(for: $1)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Productivity Insights")
                .font(.headline)

            insightRow(
                icon: "checkmark.circle.fill",
                title: "Tasks completed this week",
                value: "\(completedTasksThisWeek)",
                color: .green
            )

            insightRow(
                icon: "calendar",
                title: "Active days this week",
                value: "\(activeDaysThisWeek)/7",
                color: .blue
            )

            insightRow(
                icon: "sun.max.fill",
                title: "Most productive day",
                value: mostProductiveDay,
                color: .orange
            )

            insightRow(
                icon: "flame.fill",
                title: "Combined habit streaks",
                value: "\(totalCurrentStreak) days",
                color: .red
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func insightRow(
        icon: String,
        title: String,
        value: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ProductivityInsightsView(tasks: [], habits: [])
}
