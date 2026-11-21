import Foundation

struct HabitStreakCalculator {

    static func currentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current

        let completedDays = normalizedDates(
            habit.completionDates,
            calendar: calendar
        )

        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let anchor: Date

        if completedDays.contains(today) {
            anchor = today
        } else if completedDays.contains(yesterday) {
            anchor = yesterday
        } else {
            return 0
        }

        var streak = 0
        var currentDate = anchor

        while completedDays.contains(currentDate) {
            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: currentDate
            ) else {
                break
            }

            currentDate = previousDay
        }

        return streak
    }

    static func longestStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current

        let completedDays = normalizedDates(
            habit.completionDates,
            calendar: calendar
        ).sorted()

        guard !completedDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for index in 1..<completedDays.count {
            let previous = completedDays[index - 1]
            let next = completedDays[index]

            let difference = calendar.dateComponents(
                [.day],
                from: previous,
                to: next
            ).day

            if difference == 1 {
                current += 1
            } else if difference != 0 {
                current = 1
            }

            longest = max(longest, current)
        }

        return longest
    }

    private static func normalizedDates(
        _ dates: [Date],
        calendar: Calendar
    ) -> Set<Date> {
        Set(dates.map { calendar.startOfDay(for: $0) })
    }
}
