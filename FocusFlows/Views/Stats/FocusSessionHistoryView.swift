
import SwiftUI

struct FocusSessionHistoryView: View {

    let sessions: [FocusSession]

    private var recentSessions: [FocusSession] {
        Array(sessions.sorted {
            $0.completedAt > $1.completedAt
        }.prefix(10))
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }

    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today, \(date.formatted(date: .omitted, time: .shortened))"
        }

        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday, \(date.formatted(date: .omitted, time: .shortened))"
        }

        return date.formatted(
            date: .abbreviated,
            time: .shortened
        )
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Focus History")
                .font(.headline)

            if recentSessions.isEmpty {

                Text("Your completed focus sessions will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)

            } else {

                VStack(spacing: 14) {

                    ForEach(recentSessions) { session in

                        HStack(spacing: 12) {

                            Image(systemName: "timer")
                                .font(.title3)
                                .foregroundStyle(.indigo)
                                .frame(width: 44, height: 44)
                                .background(.indigo.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 4) {

                                Text("Focus Session")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(formatDate(session.completedAt))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(formatDuration(session.duration))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
