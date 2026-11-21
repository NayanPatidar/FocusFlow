import SwiftUI

struct TaskRow: View {

    @Binding var task: FocusTask

    var body: some View {
        Button {
            task.isCompleted.toggle()
        } label: {
            HStack {
                Text(task.title)
                    .font(.title2)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .gray : .primary)

                Spacer()

                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
