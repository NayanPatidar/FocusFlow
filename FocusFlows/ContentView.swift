import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "sun.max")
            }

            NavigationStack {
                TasksView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }

            NavigationStack {
                HabitsView()
            }
            .tabItem {
                Label("Habits", systemImage: "repeat")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
        }
    }
}
