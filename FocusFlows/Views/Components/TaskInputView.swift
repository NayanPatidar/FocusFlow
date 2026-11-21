
import SwiftUI

struct TaskInputView: View {
    @Binding var newTaskTitle: String
    @Binding var priority: TaskPriority
    @Binding var dueDate: Date?
    @Binding var category: TaskCategory

    let onAddTask: () -> Void

    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 12) {
            TextField("Enter a task", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)

            Picker("Category", selection: $category) {
                ForEach(TaskCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)

            Picker("Priority", selection: $priority) {
                ForEach(TaskPriority.allCases) { priority in
                    Text(priority.rawValue).tag(priority)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button {
                    showDatePicker.toggle()
                } label: {
                    Label(
                        dueDate == nil ? "Set Due Date" : "Change Due Date",
                        systemImage: "calendar"
                    )
                }

                Spacer()

                if let dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)

                    Button {
                        self.dueDate = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if showDatePicker {
                DatePicker(
                    "Due Date",
                    selection: $selectedDate,
                    in: Date.now...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)

                Button("Confirm Date") {
                    dueDate = selectedDate
                    showDatePicker = false
                }
                .font(.subheadline)
            }

            FocusButton(title: "Add Task") {
                onAddTask()
            }
        }
    }
}
