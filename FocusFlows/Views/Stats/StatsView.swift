import SwiftUI
import SwiftData

struct StatsView: View {

    @Query private var tasks: [FocusTask]
    @Query private var habits: [Habit]
    @Query(sort: \FocusSession.completedAt, order: .reverse)
    private var focusSessions: [FocusSession]

    @State private var selectedTrend: Trend = .focus

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Trend: String, CaseIterable, Identifiable {
        case focus = "Focus"
        case tasks = "Tasks"
        case habits = "Habits"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // 1. This week at a glance
                ProductivityInsightsView(
                    tasks: tasks,
                    habits: habits,
                    focusSessions: focusSessions
                )

                // 2. One trend chart, switchable
                trendsSection

                // 3. Day-by-day calendar
                ActivityCalendarView(
                    tasks: tasks,
                    habits: habits,
                    focusSessions: focusSessions
                )

                // 4. Habit streaks (only when there are habits)
                if !habits.isEmpty {
                    HabitStreakSection(habits: habits)
                }

                // 5. Full focus history lives on its own screen
                focusHistoryLink
            }
            .padding()
        }
        .navigationTitle("Stats")
    }

    // MARK: - Trends

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Trend", selection: $selectedTrend.animation(reduceMotion ? nil : .easeInOut(duration: 0.25))) {
                ForEach(Trend.allCases) { trend in
                    Text(trend.rawValue).tag(trend)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch selectedTrend {
                case .focus:
                    WeeklyFocusChart(sessions: focusSessions)
                case .tasks:
                    WeeklyTaskChart(tasks: tasks)
                case .habits:
                    WeeklyHabitChart(habits: habits)
                }
            }
            .transition(.opacity)
            .id(selectedTrend)
        }
    }

    // MARK: - Focus history

    private var focusHistoryLink: some View {
        NavigationLink {
            ScrollView {
                FocusSessionHistoryView(sessions: focusSessions)
                    .padding()
            }
            .navigationTitle("Focus History")
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title3)
                    .foregroundStyle(.indigo)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Focus History")
                        .font(.subheadline.weight(.semibold))

                    Text(focusSessions.isEmpty
                         ? "No sessions yet"
                         : "\(focusSessions.count) sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {

    NavigationStack {
        StatsView()
    }
    .modelContainer(
        for: [FocusTask.self, Habit.self, FocusSession.self],
        inMemory: true
    )
}
