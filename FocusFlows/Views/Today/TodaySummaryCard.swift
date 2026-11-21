import SwiftUI

struct TodaySummaryCard: View {

    let tasksDone: Int
    let tasksTotal: Int
    let habitsDone: Int
    let habitsTotal: Int

    private var message: String {
        let total = tasksTotal + habitsTotal
        let done = tasksDone + habitsDone

        if total == 0 {
            return "Start by adding a task for today."
        } else if done == total {
            return "All done for today 🎉"
        } else if done == 0 {
            return "Let's make today count."
        } else {
            return "Nice progress — keep going."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ProgressStat(
                    title: "Tasks",
                    done: tasksDone,
                    total: tasksTotal,
                    tint: .blue
                )

                Divider()
                    .frame(height: 44)

                ProgressStat(
                    title: "Habits",
                    done: habitsDone,
                    total: habitsTotal,
                    tint: .green
                )
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ProgressStat: View {

    let title: String
    let done: Int
    let total: Int
    let tint: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(done) / Double(total)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 40, height: 40)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: fraction)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(done)/\(total)")
                    .font(.title3.weight(.bold))
                    .contentTransition(.numericText())

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(done) of \(total) done today")
    }
}
