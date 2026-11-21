import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var priority: TaskPriority
    @State private var dueDate: Date?
    @State private var category: TaskCategory

    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    let onSave: (String, TaskPriority, Date?, TaskCategory) -> Void

    init(
        task: FocusTask,
        onSave: @escaping (String, TaskPriority, Date?, TaskCategory) -> Void
    ) {
        _title = State(initialValue: task.title)
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate)
        _category = State(initialValue: task.category)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Name") {
                    TextField("Task title", text: $title)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Due Date") {
                    Button(dueDate == nil ? "Set Due Date" : "Change Due Date") {
                        selectedDate = dueDate ?? Date()
                        showDatePicker.toggle()
                    }

                    if showDatePicker {
                        DatePicker(
                            "Due Date",
                            selection: $selectedDate,
                            in: Date.now...,
                            displayedComponents: .date
                        )

                        Button("Confirm Date") {
                            dueDate = Calendar.current.startOfDay(for: selectedDate)
                            showDatePicker = false
                        }
                    }

                    if dueDate != nil {
                        Button("Remove Due Date", role: .destructive) {
                            dueDate = nil
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, priority, dueDate, category)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
