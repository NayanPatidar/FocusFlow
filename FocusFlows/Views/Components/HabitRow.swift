
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
                    onToggle()
                } label: {
                    Image(systemName: habit.isCompletedToday
                          ? "checkmark.circle.fill"
                          : "circle")
                        .font(.title2)
                        .foregroundStyle(
                            habit.isCompletedToday ? .green : .secondary
                        )
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {

                    Text(habit.name)
                        .font(.headline)
                        .strikethrough(habit.isCompletedToday)

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

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            HStack {
                Label("\(currentStreak) day streak", systemImage: "flame.fill")
                    .foregroundStyle(currentStreak > 0 ? .orange : .secondary)

                Spacer()

                Text("Best: \(longestStreak) days")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
