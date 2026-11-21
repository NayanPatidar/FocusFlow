import SwiftUI

struct TaskInputView: View {
    @Binding var newTaskTitle: String
    let onAddTask: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TextField("Enter a task", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)

            FocusButton(title: "Add Task") {
                onAddTask()
            }
        }
    }
}
