import SwiftUI

struct NewHabitSheet: View {

    let onAdd: (String, Date?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var name = ""
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 9,
        minute: 0,
        second: 0,
        of: .now
    ) ?? .now

    @FocusState private var isNameFocused: Bool

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("e.g. Read for 20 minutes", text: $name)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                        .onSubmit(add)
                }

                Section {
                    Toggle("Daily Reminder", isOn: $reminderEnabled.animation(reduceMotion ? nil : .default))

                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add)
                        .disabled(!canAdd)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
        .presentationDetents([.medium])
    }

    private func add() {
        guard canAdd else { return }
        onAdd(name, reminderEnabled ? reminderTime : nil)
        dismiss()
    }
}
