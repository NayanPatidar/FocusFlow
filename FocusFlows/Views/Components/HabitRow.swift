import SwiftUI

struct HabitRow: View {

    let habit: Habit
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var currentStreak: Int {
        HabitStreakCalculator.currentStreak(for: habit)
    }

    private var longestStreak: Int {
        HabitStreakCalculator.longestStreak(for: habit)
    }

    private var reminderFormattedTime: String {
        guard let reminderTime = habit.reminderTime else { return "" }
        return reminderTime.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        VStack(spacing: 12) {

            HStack(spacing: 12) {

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                        onToggle()
                    }
                } label: {
                    Image(systemName: habit.isCompletedToday
                          ? "checkmark.circle.fill"
                          : "circle")
                        .font(.title2)
                        .foregroundStyle(
                            habit.isCompletedToday ? .green : .secondary
                        )
                        .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    habit.isCompletedToday
                        ? "Mark \(habit.name) incomplete"
                        : "Mark \(habit.name) complete"
                )
                .accessibilityHint("Double tap to change today's habit status")

                VStack(alignment: .leading, spacing: 4) {

                    Text(habit.name)
                        .font(.headline)
                        .strikethrough(habit.isCompletedToday)
                        .accessibilityAddTraits(.isHeader)

                    Text(habit.isCompletedToday ? "Completed today" : "Not completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let reminderTime = habit.reminderTime {
                        Label(
                            reminderTime.formatted(date: .omitted, time: .shortened),
                            systemImage: "bell.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .accessibilityLabel("Daily reminder at \(reminderTime.formatted(date: .omitted, time: .shortened))")
                    }
                }

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit habit: \(habit.name)")
                .accessibilityHint("Double tap to edit this habit")

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete habit: \(habit.name)")
                .accessibilityHint("Double tap to delete this habit")
            }

            Divider()

            HStack {
                Label("\(currentStreak) day streak", systemImage: "flame.fill")
                    .foregroundStyle(currentStreak > 0 ? .orange : .secondary)
                    .accessibilityLabel("Current streak: \(currentStreak) days")

                Spacer()

                Text("Best: \(longestStreak) days")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Longest streak: \(longestStreak) days")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.25), value: habit.isCompletedToday)
        .sensoryFeedback(.success, trigger: habit.isCompletedToday)
    }
}
