
import SwiftUI

struct ProductivityInsightsView: View {

    let tasks: [FocusTask]
    let habits: [Habit]
    let focusSessions: [FocusSession]

    // MARK: - Task Insights

    private var completedTasksThisWeek: Int {
        tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }

            return Calendar.current.isDate(
                completedAt,
                equalTo: .now,
                toGranularity: .weekOfYear
            )
        }.count
    }

    private var taskCompletionRate: Int {
        guard !tasks.isEmpty else { return 0 }

        return Int(
            (Double(completedTasks) / Double(tasks.count)) * 100
        )
    }

    private var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }

    // MARK: - Focus Insights

    private var focusSessionsThisWeek: [FocusSession] {
        focusSessions.filter {
            Calendar.current.isDate(
                $0.completedAt,
                equalTo: .now,
                toGranularity: .weekOfYear
            )
        }
    }

    private var focusTimeThisWeek: TimeInterval {
        focusSessionsThisWeek.reduce(0) {
            $0 + $1.duration
        }
    }

    private var focusSessionsCountThisWeek: Int {
        focusSessionsThisWeek.count
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }

    // MARK: - Activity

    private var activeDaysThisWeek: Int {
        let calendar = Calendar.current

        return (0..<7).filter { offset in

            guard let day = calendar.date(
                byAdding: .day,
                value: -6 + offset,
                to: calendar.startOfDay(for: .now)
            ) else { return false }

            return tasks.contains { task in

                guard let completedAt = task.completedAt else {
                    return false
                }

                return calendar.isDate(
                    completedAt,
                    inSameDayAs: day
                )
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

                guard let completedAt = task.completedAt else {
                    return false
                }

                return calendar.isDate(
                    completedAt,
                    inSameDayAs: day
                )
            }.count

            return (day, count)
        }

        guard let bestDay = dailyCounts.max(by: { $0.1 < $1.1 }),
              bestDay.1 > 0 else {
            return "No activity yet"
        }

        return bestDay.0.formatted(
            .dateTime.weekday(.wide)
        )
    }

    // MARK: - Habit Insights

    private var totalCurrentStreak: Int {
        habits.reduce(0) {
            $0 + HabitStreakCalculator.currentStreak(for: $1)
        }
    }

    // MARK: - View

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("This Week")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                tile(
                    value: "\(completedTasksThisWeek)",
                    title: "Tasks done",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                tile(
                    value: formatDuration(focusTimeThisWeek),
                    title: "Focus time",
                    icon: "clock.fill",
                    color: .indigo
                )

                tile(
                    value: "\(focusSessionsCountThisWeek)",
                    title: "Focus sessions",
                    icon: "timer",
                    color: .pink
                )

                tile(
                    value: "\(activeDaysThisWeek)/7",
                    title: "Active days",
                    icon: "calendar",
                    color: .blue
                )
            }

            if !tasks.isEmpty {
                highlights
            }
        }
    }

    // MARK: - Highlights

    private var highlights: some View {
        VStack(spacing: 10) {
            highlightRow(
                icon: "sun.max.fill",
                title: "Most productive day",
                value: mostProductiveDay,
                color: .orange
            )

            Divider()

            highlightRow(
                icon: "chart.pie.fill",
                title: "Overall task completion",
                value: "\(taskCompletionRate)%",
                color: .teal
            )

            if totalCurrentStreak > 0 {
                Divider()

                highlightRow(
                    icon: "flame.fill",
                    title: "Combined habit streaks",
                    value: "\(totalCurrentStreak) days",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Reusable Views

    private func tile(
        value: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) this week: \(value)")
    }

    private func highlightRow(
        icon: String,
        title: String,
        value: String,
        color: Color
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {

    ProductivityInsightsView(
        tasks: [],
        habits: [],
        focusSessions: []
    )
}
