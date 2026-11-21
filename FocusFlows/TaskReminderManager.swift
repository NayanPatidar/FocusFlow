import Foundation
import UserNotifications

final class TaskReminderManager {

    static let shared = TaskReminderManager()

    private let center = UNUserNotificationCenter.current()

    /// Hour of the day a task reminder fires on its due date.
    static let reminderHour = 9

    private init() {}

    /// Due dates are calendar days, so the reminder fires at a fixed time
    /// on that day rather than at midnight.
    private func reminderDate(for dueDate: Date) -> Date? {
        Calendar.current.date(
            bySettingHour: Self.reminderHour,
            minute: 0,
            second: 0,
            of: dueDate
        )
    }

    // MARK: - Schedule Reminder

    func scheduleReminder(for task: FocusTask) {

        guard let dueDate = task.dueDate,
              !task.isCompleted,
              let fireDate = reminderDate(for: dueDate),
              fireDate > Date() else {
            cancelReminder(for: task)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: task),
            content: content,
            trigger: trigger
        )

        center.add(request) { error in

            if let error {
                print("[TaskReminder] Scheduling failed: \(error)")
            } else {
                print("[TaskReminder] Scheduled: \(task.title)")
            }
        }
    }

    // MARK: - Cancel Reminder

    func cancelReminder(for task: FocusTask) {

        center.removePendingNotificationRequests(
            withIdentifiers: [reminderIdentifier(for: task)]
        )

        print("[TaskReminder] Cancelled: \(task.title)")
    }

    // MARK: - Check Pending Reminders

    func printPendingReminders() {

        center.getPendingNotificationRequests { requests in

            print("---- Pending Notifications ----")

            for request in requests {
                print("ID: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                print("Trigger: \(String(describing: request.trigger))")
            }

            if requests.isEmpty {
                print("No pending notifications.")
            }

            print("-----------------------------")
        }
    }

    // MARK: - Identifier

    private func reminderIdentifier(for task: FocusTask) -> String {
        "task-reminder-\(task.id.uuidString)"
    }
    
    func requestNotificationPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("[TaskReminder] Permission error: \(error)")
                return
            }

            print("[TaskReminder] Permission granted: \(granted)")
        }
    }
}
