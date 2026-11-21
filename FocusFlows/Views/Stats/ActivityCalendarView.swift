import SwiftUI

struct ActivityCalendarView: View {

    let tasks: [FocusTask]
    let habits: [Habit]
    let focusSessions: [FocusSession]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    private let calendar = Calendar.current

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(
            of: .month,
            for: displayedMonth
        ) else {
            return []
        }

        let firstDay = monthInterval.start
        let numberOfDays = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingSpaces = (weekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)

        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        let trailingSpaces = (7 - days.count % 7) % 7
        days.append(contentsOf: Array(repeating: nil, count: trailingSpaces))

        return days
    }

    private var selectedTasks: [FocusTask] {
        tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: selectedDate)
        }
    }

    private var selectedHabits: [Habit] {
        habits.filter { habit in
            habit.completionDates.contains { date in
                calendar.isDate(date, inSameDayAs: selectedDate)
            }
        }
    }

    private var selectedFocusSessions: [FocusSession] {
        focusSessions.filter {
            calendar.isDate($0.completedAt, inSameDayAs: selectedDate)
        }
    }

    private var selectedFocusTime: TimeInterval {
        selectedFocusSessions.reduce(0) { $0 + $1.duration }
    }

    private var hasActivity: Bool {
        !selectedTasks.isEmpty ||
        !selectedHabits.isEmpty ||
        !selectedFocusSessions.isEmpty
    }

    private func hasTaskActivity(on date: Date) -> Bool {
        tasks.contains {
            guard let completedAt = $0.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: date)
        }
    }

    private func hasHabitActivity(on date: Date) -> Bool {
        habits.contains { habit in
            habit.completionDates.contains {
                calendar.isDate($0, inSameDayAs: date)
            }
        }
    }

    private func hasFocusActivity(on date: Date) -> Bool {
        focusSessions.contains {
            calendar.isDate($0.completedAt, inSameDayAs: date)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }
    
    private var orderedWeekdays: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1

        let firstPart = Array(symbols[startIndex...])
        let secondPart = Array(symbols[..<startIndex])

        return firstPart + secondPart
    }

    var body: some View {
        VStack(spacing: 20) {

            // Month Navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthTitle)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 8
            ) {
                ForEach(orderedWeekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Days
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 8
            ) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in

                    if let date {
                        calendarDay(date)
                    } else {
                        Color.clear
                            .frame(height: 48)
                    }
                }
            }

            // Activity Legend
            HStack(spacing: 16) {
                legendItem(color: .green, title: "Tasks")
                legendItem(color: .orange, title: "Habits")
                legendItem(color: .indigo, title: "Focus")
            }
            .font(.caption)

            Divider()

            // Selected Date Details
            selectedDayDetails
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func calendarDay(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: 5) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isSelected || isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : .primary)

                HStack(spacing: 3) {
                    if hasTaskActivity(on: date) {
                        Circle()
                            .fill(isSelected ? .white : .green)
                            .frame(width: 5, height: 5)
                    }

                    if hasHabitActivity(on: date) {
                        Circle()
                            .fill(isSelected ? .white : .orange)
                            .frame(width: 5, height: 5)
                    }

                    if hasFocusActivity(on: date) {
                        Circle()
                            .fill(isSelected ? .white : .indigo)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                if isSelected {
                    Circle()
                        .fill(Color.accentColor)
                } else if isToday {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var selectedDayDetails: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.headline)

            if !hasActivity {
                ContentUnavailableView(
                    "No Activity",
                    systemImage: "calendar",
                    description: Text("No recorded activity for this day.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            } else {

                // Tasks
                activityRow(
                    title: "Tasks Completed",
                    value: "\(selectedTasks.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                // Habits
                activityRow(
                    title: "Habits Completed",
                    value: "\(selectedHabits.count)",
                    icon: "flame.fill",
                    color: .orange
                )

                // Focus Sessions
                activityRow(
                    title: "Focus Sessions",
                    value: "\(selectedFocusSessions.count)",
                    icon: "timer",
                    color: .indigo
                )

                // Focus Time
                activityRow(
                    title: "Focus Time",
                    value: formatDuration(selectedFocusTime),
                    icon: "clock.fill",
                    color: .blue
                )

                if !selectedTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed Tasks")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(selectedTasks) { task in
                            Label(task.title, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !selectedHabits.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed Habits")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(selectedHabits) { habit in
                            Label(habit.name, systemImage: "flame.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func activityRow(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .foregroundStyle(.secondary)
        }
    }

    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) else {
            return
        }

        displayedMonth = newMonth

        // Select the first day of the newly displayed month
        if let monthInterval = calendar.dateInterval(of: .month, for: newMonth) {
            selectedDate = calendar.startOfDay(for: monthInterval.start)
        }
    }
}
