import SwiftUI

struct TaskRow: View {
    @Binding var task: FocusTask
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted
                      ? "checkmark.circle.fill"
                      : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .foregroundStyle(priorityColor)

                    if let dueDate = task.dueDate {
                        Text("•")
                            .foregroundStyle(.secondary)

                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
