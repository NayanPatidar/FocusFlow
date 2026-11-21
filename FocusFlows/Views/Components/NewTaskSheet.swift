import SwiftUI

/// Full "New Task" form in a sheet. Shared by Today (options button) and Tasks (+ button).
struct NewTaskSheet: View {

    let defaultDueDate: Date?
    let onAdd: (String, TaskPriority, Date?, TaskCategory) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var priority: TaskPriority = .medium
    @State private var dueDate: Date?
    @State private var category: TaskCategory = .other

    init(
        defaultDueDate: Date? = nil,
        onAdd: @escaping (String, TaskPriority, Date?, TaskCategory) -> Void
    ) {
        self.defaultDueDate = defaultDueDate
        self.onAdd = onAdd
        _dueDate = State(initialValue: defaultDueDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                TaskInputView(
                    newTaskTitle: $title,
                    priority: $priority,
                    dueDate: $dueDate,
                    category: $category
                ) {
                    onAdd(title, priority, dueDate, category)
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
