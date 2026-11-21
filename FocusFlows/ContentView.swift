
import SwiftUI

enum AppTab: Hashable {
    case today, tasks, habits, stats, focus, settings
}

struct ContentView: View {

    @State private var selectedTab: AppTab = .today

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

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
        .preferredColorScheme(preferredColorScheme)
    }
}
