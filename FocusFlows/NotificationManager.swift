
import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            print("[Notifications] Permission granted: \(granted)")
            return granted
        } catch {
            print("[Notifications] Permission error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Notification

    func scheduleNotification(
        title: String,
        body: String,
        after seconds: TimeInterval
    ) {
        guard seconds > 0 else { return }

        cancelNotification()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "focusflow.timer",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("[Notifications] Scheduling error: \(error)")
            } else {
                print("[Notifications] Scheduled successfully")
            }
        }
    }

    // MARK: - Cancel Notification

    func cancelNotification() {
        center.removePendingNotificationRequests(
            withIdentifiers: ["focusflow.timer"]
        )
    }

    // MARK: - Foreground Presentation

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
