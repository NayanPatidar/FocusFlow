
import SwiftUI
import SwiftData
import UIKit

enum AppTab: Hashable {
    case today, tasks, habits, stats, focus
}

struct ContentView: View {

    @State private var selectedTab: AppTab = .today

    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("appAppearance") private var appearance = "system"

    private var preferredColorScheme: ColorScheme? {
        switch appearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {
                TodayView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Today", systemImage: "sun.max")
            }
            .tag(AppTab.today)

            NavigationStack {
                TasksView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(AppTab.tasks)

            NavigationStack {
                HabitsView()
            }
            .tabItem {
                Label("Habits", systemImage: "repeat")
            }
            .tag(AppTab.habits)

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            .tag(AppTab.stats)

            NavigationStack {
                FocusTimerView()
            }
            .tabItem {
                Label("Focus", systemImage: "timer")
            }
            .tag(AppTab.focus)
        }
        .preferredColorScheme(preferredColorScheme)
        // Habits store "done today" as a flag, so reset it whenever a new day
        // may have started: on launch, on return from background, and at midnight.
        .onAppear(perform: refreshHabitsForToday)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshHabitsForToday()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            refreshHabitsForToday()
        }
    }

    private func refreshHabitsForToday() {
        let habits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
        HabitViewModel().refreshDailyStatus(habits, context: context)
    }
}
