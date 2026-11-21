import SwiftUI

struct EditHabitView: View {

    let habit: Habit
    let onSave: (String, Date?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date

    init(habit: Habit, onSave: @escaping (String, Date?) -> Void) {
        self.habit = habit
        self.onSave = onSave

        _name = State(initialValue: habit.name)
        _reminderEnabled = State(initialValue: habit.reminderTime != nil)

        _reminderTime = State(
            initialValue: habit.reminderTime ?? Calendar.current.date(
                bySettingHour: 9,
                minute: 0,
                second: 0,
                of: .now
            ) ?? .now
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $name)
                }

                Section("Reminder") {
                    Toggle("Enable Reminder", isOn: $reminderEnabled)

                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
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

                        onSave(
                            trimmedName,
                            reminderEnabled ? reminderTime : nil
                        )

                        dismiss()
                    }
                }
            }
        }
    }
}
