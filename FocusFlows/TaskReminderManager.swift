import Foundation
import UserNotifications

final class TaskReminderManager {

    static let shared = TaskReminderManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Schedule Reminder

    func scheduleReminder(for task: FocusTask) {

        print("---- Scheduling Reminder ----")
        print("Task: \(task.title)")
        print("Completed: \(task.isCompleted)")
        print("Due Date: \(String(describing: task.dueDate))")
        print("Current Date: \(Date())")

        guard let dueDate = task.dueDate,
              !task.isCompleted,
              dueDate > Date() else {

            print("[TaskReminder] Guard failed for: \(task.title)")

            if let dueDate = task.dueDate {
                print("Due date is in future: \(dueDate > Date())")
            } else {
                print("Due date is NIL")
            }

            print("Task completed: \(task.isCompleted)")

            cancelReminder(for: task)
            return
        }

        print("[TaskReminder] Guard passed — scheduling now")

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
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
