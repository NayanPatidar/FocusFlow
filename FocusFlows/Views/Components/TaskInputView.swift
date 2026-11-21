import SwiftUI

struct TaskInputView: View {

    @Binding var newTaskTitle: String
    @Binding var priority: TaskPriority
    @Binding var dueDate: Date?
    @Binding var category: TaskCategory

    let onAddTask: () -> Void

    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @FocusState private var isTaskFieldFocused: Bool

    var body: some View {

        VStack(spacing: 12) {

            TextField("Enter a task", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .focused($isTaskFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    addTask()
                }

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

            // MARK: - Due Date

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    Button {
                        isTaskFieldFocused = false
                        dueDate = Calendar.current.startOfDay(for: Date())
                        showDatePicker = false
                    } label: {
                        Label("Today", systemImage: "sun")
                    }

                    Button {
                        isTaskFieldFocused = false
                        dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                        showDatePicker = false
                    } label: {
                        Label("Tomorrow", systemImage: "sunrise")
                    }
                }

                HStack {

                    Button {
                        selectedDate = dueDate ?? Date()
                        showDatePicker.toggle()
                        isTaskFieldFocused = false
                    } label: {
                        Label(
                            dueDate == nil ? "Choose Date" : "Change Date",
                            systemImage: "calendar"
                        )
                    }

                    Spacer()

                    if let dueDate {
                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button {
                            self.dueDate = nil
                            showDatePicker = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Remove due date")
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
                        dueDate = Calendar.current.startOfDay(for: selectedDate)
                        showDatePicker = false
                    }
                    .font(.subheadline)
                }
            }
            .transition(.opacity)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showDatePicker)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: dueDate)

            FocusButton(title: "Add Task") {
                addTask()
            }
        }
    }

    // MARK: - Add Task

    private func addTask() {

        guard !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        isTaskFieldFocused = false
        showDatePicker = false

        onAddTask()
    }
}
