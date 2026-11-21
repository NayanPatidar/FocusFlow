import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String

    let onSave: (String) -> Void

    init(taskTitle: String, onSave: @escaping (String) -> Void) {
        _title = State(initialValue: taskTitle)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Name") {
                    TextField("Task title", text: $title)
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
                        onSave(title)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
