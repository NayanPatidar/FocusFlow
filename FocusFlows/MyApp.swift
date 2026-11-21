import SwiftUI
import SwiftData

@main
struct MyApp: App {

    init() {
        // Sets itself as the notification delegate so reminders show as
        // banners while the app is open.
        _ = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            FocusTask.self,
            Habit.self,
            FocusSession.self
        ])    }
}
