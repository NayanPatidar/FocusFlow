import SwiftUI

struct TaskRow: View {
    @Binding var task: FocusTask
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Button {
                task.isCompleted.toggle()
            } label: {
                HStack {
                    Text(task.title)
                        .font(.title3)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .gray : .primary)

                    Spacer()

                    Image(systemName: task.isCompleted
                          ? "checkmark.circle.fill"
                          : "circle")
                        .foregroundStyle(task.isCompleted ? .green : .secondary)
                }
            }
            .buttonStyle(.plain)

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}
