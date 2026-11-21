
import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var tasks: [FocusTask]
    @Query private var habits: [Habit]

    private var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var completedHabitsToday: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

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
                }

                WeeklyTaskChart(tasks: tasks)
                WeeklyHabitChart(habits: habits)
                HabitStreakSection(habits: habits)
                ProductivityInsightsView(tasks: tasks, habits: habits)
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
    .modelContainer(for: [FocusTask.self, Habit.self], inMemory: true)
}
