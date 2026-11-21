
import SwiftUI
import SwiftData

struct StatsView: View {

    @Query private var tasks: [FocusTask]
    @Query private var habits: [Habit]
    @Query(sort: \FocusSession.completedAt, order: .reverse)
    private var focusSessions: [FocusSession]

    private var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var completedHabitsToday: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    private var sessionsToday: [FocusSession] {
        focusSessions.filter {
            Calendar.current.isDateInToday($0.completedAt)
        }
    }

    private var focusTimeToday: TimeInterval {
        sessionsToday.reduce(0) { $0 + $1.duration }
    }

    private var totalFocusTime: TimeInterval {
        focusSessions.reduce(0) { $0 + $1.duration }
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

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                header
                
                ActivityCalendarView(
                    tasks: tasks,
                    habits: habits,
                    focusSessions: focusSessions
                )

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 16
                ) {

                    statCard(
                        title: "Tasks Completed",
                        value: "\(completedTasks)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    statCard(
                        title: "Total Tasks",
                        value: "\(tasks.count)",
                        icon: "list.bullet",
                        color: .blue
                    )

                    statCard(
                        title: "Total Habits",
                        value: "\(habits.count)",
                        icon: "repeat",
                        color: .orange
                    )

                    statCard(
                        title: "Habits Completed",
                        value: "\(completedHabitsToday)/\(habits.count)",
                        icon: "flame.fill",
                        color: .purple
                    )

                    statCard(
                        title: "Focus Time Today",
                        value: formatDuration(focusTimeToday),
                        icon: "clock.fill",
                        color: .indigo
                    )

                    statCard(
                        title: "Sessions Today",
                        value: "\(sessionsToday.count)",
                        icon: "timer",
                        color: .pink
                    )

                    statCard(
                        title: "Total Focus Sessions",
                        value: "\(focusSessions.count)",
                        icon: "target",
                        color: .teal
                    )

                    statCard(
                        title: "Total Focus Time",
                        value: formatDuration(totalFocusTime),
                        icon: "hourglass",
                        color: .mint
                    )
                }
                
                if focusSessions.isEmpty {
                    EmptyStateView(
                        systemImage: "timer",
                        title: "No Focus Sessions Yet",
                        message: "Complete your first focus session to see your focus history and analytics."
                    )
                } else {
                    WeeklyFocusChart(sessions: focusSessions)
                    FocusSessionHistoryView(sessions: focusSessions)
                }

                WeeklyTaskChart(tasks: tasks)

                WeeklyHabitChart(habits: habits)

                HabitStreakSection(habits: habits)

                ProductivityInsightsView(
                    tasks: tasks,
                    habits: habits,
                    focusSessions: focusSessions
                )
            }
            .padding()
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text("Your Progress")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("A snapshot of your productivity.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 14) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {

    NavigationStack {
        StatsView()
    }
    .modelContainer(
        for: [FocusTask.self, Habit.self, FocusSession.self],
        inMemory: true
    )
}
