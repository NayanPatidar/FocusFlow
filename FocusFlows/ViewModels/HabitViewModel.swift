
import Foundation
import Observation
import SwiftData

@Observable
class HabitViewModel {

    func addHabit(name: String, context: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return }

        let habit = Habit(name: trimmedName)
        context.insert(habit)
        save(context)
    }

    func deleteHabit(_ habit: Habit, context: ModelContext) {
        context.delete(habit)
        save(context)
    }

    func toggleHabit(_ habit: Habit, context: ModelContext) {
        if habit.isCompletedToday {
            habit.isCompletedToday = false
            habit.completedAt = nil
        } else {
            habit.isCompletedToday = true
            habit.completedAt = .now
        }

        save(context)
    }

    func refreshDailyStatus(_ habits: [Habit], context: ModelContext) {
        let calendar = Calendar.current
        var changed = false

        for habit in habits {
            guard let completedAt = habit.completedAt else {
                if habit.isCompletedToday {
                    habit.isCompletedToday = false
                    changed = true
                }
                continue
            }

            if !calendar.isDateInToday(completedAt) {
                habit.isCompletedToday = false
                habit.completedAt = nil
                changed = true
            }
        }

        if changed {
            save(context)
        }
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save habit: \(error)")
        }
    }
}
