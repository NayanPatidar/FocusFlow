import SwiftUI

struct HabitStreakSection: View {
    let habits: [Habit]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Streaks")
                .font(.headline)

            if habits.isEmpty {
                Text("Start tracking habits to build streaks.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                VStack(spacing: 12) {
                    ForEach(habits) { habit in
                        streakRow(for: habit)

                        if habit.id != habits.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func streakRow(for habit: Habit) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Current: \(HabitStreakCalculator.currentStreak(for: habit)) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(HabitStreakCalculator.longestStreak(for: habit))")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Best streak")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HabitStreakSection(habits: [])
}
