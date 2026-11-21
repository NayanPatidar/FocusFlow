import Foundation
import Observation
import SwiftData

@Observable
class HabitViewModel {

    // MARK: - Add Habit

    func addHabit(
        name: String,
        reminderTime: Date? = nil,
        context: ModelContext
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let habit = Habit(
            name: trimmedName,
            reminderTime: reminderTime
        )

        context.insert(habit)
        save(context)

        if reminderTime != nil {
            Task {
                let granted = await HabitReminderManager.shared
                    .requestNotificationPermission()

                if granted {
                    HabitReminderManager.shared.scheduleReminder(for: habit)
                } else {
                    print("[HabitReminder] Permission not granted")
                }
            }
        }
    }

    // MARK: - Delete Habit

    func deleteHabit(_ habit: Habit, context: ModelContext) {
        HabitReminderManager.shared.cancelReminder(for: habit)

        context.delete(habit)
        save(context)
    }

    // MARK: - Toggle Habit

    func toggleHabit(_ habit: Habit, context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if habit.isCompletedToday {
            habit.isCompletedToday = false
            habit.completedAt = nil

            habit.completionDates.removeAll {
                calendar.isDate($0, inSameDayAs: today)
            }
        } else {
            habit.isCompletedToday = true
            habit.completedAt = .now

            let alreadyRecorded = habit.completionDates.contains {
                calendar.isDate($0, inSameDayAs: today)
            }

            if !alreadyRecorded {
                habit.completionDates.append(today)
            }
        }

        save(context)
    }

    // MARK: - Refresh Daily Status

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

    // MARK: - Save

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save habit: \(error)")
        }
    }
}
