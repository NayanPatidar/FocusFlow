
import SwiftUI
import SwiftData
import Charts

struct WeeklyTaskChart: View {
    let tasks: [FocusTask]

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

            let count = tasks.filter { task in
                guard let completedAt = task.completedAt else {
                    return false
                }

                return calendar.isDate(completedAt, inSameDayAs: day)
            }.count

            return (day, count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Activity")
                .font(.headline)

            Text("Tasks completed over the last 7 days")
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart(dailyCompletions, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Tasks", item.count)
                )
                .foregroundStyle(.blue.gradient)
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
    WeeklyTaskChart(tasks: [])
}
