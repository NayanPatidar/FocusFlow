
import SwiftUI
import SwiftData
import Charts

struct WeeklyFocusChart: View {

    let sessions: [FocusSession]

    private struct DailyFocus: Identifiable {
        let date: Date
        let minutes: Int

        var id: Date { date }
    }

    private var weeklyData: [DailyFocus] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let lastSevenDays = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()

        return lastSevenDays.map { day in

            let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: day
            )!

            let totalSeconds = sessions
                .filter {
                    $0.completedAt >= day &&
                    $0.completedAt < nextDay
                }
                .reduce(0) { $0 + $1.duration }

            return DailyFocus(
                date: day,
                minutes: Int(totalSeconds / 60)
            )
        }
    }

    private var totalWeeklyMinutes: Int {
        weeklyData.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {

                Text("Focus Activity")
                    .font(.headline)

                Text("Last 7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {

                Text("\(totalWeeklyMinutes)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("minutes focused")
                    .foregroundStyle(.secondary)
            }

            Chart(weeklyData) { day in

                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Minutes", day.minutes)
                )
                .cornerRadius(6)
                .foregroundStyle(.indigo)
            }
            .chartXAxis {

                AxisMarks(values: weeklyData.map(\.date)) { value in

                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {

                AxisMarks(position: .leading)
            }
            .frame(height: 220)

            if totalWeeklyMinutes == 0 {

                Text("Complete a focus session to see your activity here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
