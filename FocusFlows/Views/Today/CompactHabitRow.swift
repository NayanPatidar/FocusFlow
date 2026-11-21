import SwiftUI

struct CompactHabitRow: View {

    let habit: Habit
    let onToggle: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentStreak: Int {
        HabitStreakCalculator.currentStreak(for: habit)
    }

    var body: some View {
        Button {
            if reduceMotion {
                onToggle()
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                    onToggle()
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(habit.isCompletedToday ? .green : .secondary)
                    .symbolEffect(.bounce, value: reduceMotion ? false : habit.isCompletedToday)

                Text(habit.name)
                    .foregroundStyle(habit.isCompletedToday ? .secondary : .primary)
                    .strikethrough(habit.isCompletedToday)

                Spacer()

                if currentStreak > 0 {
                    Label("\(currentStreak)", systemImage: "flame.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: habit.isCompletedToday)
        .sensoryFeedback(.success, trigger: habit.isCompletedToday)
        .accessibilityLabel(
            habit.isCompletedToday
                ? "Mark \(habit.name) incomplete"
                : "Mark \(habit.name) complete"
        )
        .accessibilityValue(currentStreak > 0 ? "\(currentStreak) day streak" : "")
    }
}
