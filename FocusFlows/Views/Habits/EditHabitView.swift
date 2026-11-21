
import SwiftUI

struct EditHabitView: View {
    let habit: Habit
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    init(habit: Habit, onSave: @escaping (String) -> Void) {
        self.habit = habit
        self.onSave = onSave
        _name = State(initialValue: habit.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $name)
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                        guard !trimmedName.isEmpty else { return }

                        onSave(trimmedName)
                        dismiss()
                    }
                }
            }
        }
    }
}
