import SwiftUI

struct TaskRow: View {

    let task: FocusTask
    let onToggle: () -> Void
    let onEdit: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {

            Button {
                if reduceMotion {
                    onToggle()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                        onToggle()
                    }
                }
            } label: {
                Image(systemName: task.isCompleted
                      ? "checkmark.circle.fill"
                      : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .font(.title2)
                    .scaleEffect(task.isCompleted ? 1.1 : 1.0)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark task incomplete" : "Mark task complete")
            .accessibilityHint("Double tap to change task completion status")

            VStack(alignment: .leading, spacing: 6) {

                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: 8) {
                    Text(task.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.blue)

                    Text("•")
                        .foregroundStyle(.secondary)

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

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: task.isCompleted)
        .sensoryFeedback(.success, trigger: task.isCompleted)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
