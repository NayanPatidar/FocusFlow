import SwiftUI
import Charts

struct WeeklyHabitChart: View {
    let habits: [Habit]

    private var dailyCompletions: [(day: Date, count: Int)] {
        let calendar = Calendar.current

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(
                byAdding: .day,
                value: -6 + offset,
                to: calendar.startOfDay(for: .now)
            ) else {
                return nil
            }

            let count = habits.filter { habit in
                habit.completionDates.contains {
                    calendar.isDate($0, inSameDayAs: day)
                }
            }.count

            return (day, count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Consistency")
                .font(.headline)

            Text("Habits completed each day")
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart(dailyCompletions, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Habits", item.count)
                )
                .foregroundStyle(.green.gradient)
                .cornerRadius(6)
            }
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    WeeklyHabitChart(habits: [])
}
