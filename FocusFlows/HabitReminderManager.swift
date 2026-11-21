import Foundation
import UserNotifications

final class HabitReminderManager {

    static let shared = HabitReminderManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("[HabitReminder] Permission error: \(error)")
            return false
        }
    }

    // MARK: - Schedule

    func scheduleReminder(for habit: Habit) {

        guard let reminderTime = habit.reminderTime else {
            cancelReminder(for: habit)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to work on: \(habit.name)"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: reminderTime
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: habit),
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error {
                print("[HabitReminder] Scheduling error: \(error)")
            } else {
                print("[HabitReminder] Scheduled: \(habit.name)")
            }
        }
    }

    // MARK: - Cancel

    func cancelReminder(for habit: Habit) {

        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier(for: habit)]
        )

        print("[HabitReminder] Cancelled: \(habit.name)")
    }

    // MARK: - Identifier

    private func notificationIdentifier(for habit: Habit) -> String {
        "habit-reminder-\(habit.id.uuidString)"
    }
}
