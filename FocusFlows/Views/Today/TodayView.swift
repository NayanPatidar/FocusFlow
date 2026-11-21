import SwiftUI
import SwiftData

struct TodayView: View {

    @Binding var selectedTab: AppTab

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query private var tasks: [FocusTask]
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var viewModel = TaskViewModel()
    @State private var habitViewModel = HabitViewModel()

    @State private var editingTask: FocusTask?
    @State private var showTaskOptions = false
    @State private var showCompleted = false

    // Full-options sheet state
    @State private var newTaskTitle = ""
    @State private var newTaskPriority: TaskPriority = .medium
    @State private var newTaskDueDate: Date? = Calendar.current.startOfDay(for: .now)
    @State private var newTaskCategory: TaskCategory = .other

    private let maxVisibleTasks = 5

    // MARK: - Derived data

    private var startOfToday: Date {
        Calendar.current.startOfDay(for: .now)
    }

    /// Incomplete tasks that are overdue, due today, or have no due date.
    /// Overdue first, then by priority.
    private var todayTasks: [FocusTask] {
        let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? .now

        return tasks
            .filter { task in
                guard !task.isCompleted else { return false }
                guard let due = task.dueDate else { return true }
                return due < endOfToday
            }
            .sorted { lhs, rhs in
                let lhsOverdue = isOverdue(lhs)
                let rhsOverdue = isOverdue(rhs)
                if lhsOverdue != rhsOverdue { return lhsOverdue }
                return priorityRank(lhs.priority) > priorityRank(rhs.priority)
            }
    }

    private var completedTodayTasks: [FocusTask] {
        tasks.filter { task in
            guard task.isCompleted, let completedAt = task.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }
    }

    private var completedHabitCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private func isOverdue(_ task: FocusTask) -> Bool {
        guard !task.isCompleted, let due = task.dueDate else { return false }
        return due < startOfToday
    }

    private func priorityRank(_ priority: TaskPriority) -> Int {
        switch priority {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }

    private var listAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                TodaySummaryCard(
                    tasksDone: completedTodayTasks.count,
                    tasksTotal: completedTodayTasks.count + todayTasks.count,
                    habitsDone: completedHabitCount,
                    habitsTotal: habits.count
                )

                QuickAddTaskBar(
                    onAdd: { title in
                        withAnimation(listAnimation) {
                            viewModel.addTask(
                                title: title,
                                dueDate: startOfToday,
                                context: context
                            )
                        }
                    },
                    onShowOptions: {
                        showTaskOptions = true
                    }
                )

                tasksSection
                habitsSection
                focusShortcut
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(listAnimation, value: todayTasks.count)
        .animation(listAnimation, value: completedTodayTasks.count)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $editingTask) { task in
            EditTaskView(task: task) { updatedTitle, updatedPriority, updatedDueDate, updatedCategory in
                viewModel.updateTask(
                    task,
                    title: updatedTitle,
                    priority: updatedPriority,
                    dueDate: updatedDueDate,
                    category: updatedCategory,
                    context: context
                )
            }
        }
        .sheet(isPresented: $showTaskOptions) {
            taskOptionsSheet
        }
        .onAppear {
            habitViewModel.refreshDailyStatus(habits, context: context)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(greeting)
                .font(.largeTitle.weight(.bold))
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Tasks

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Today's Tasks",
                actionTitle: "See all",
                action: { selectedTab = .tasks }
            )

            VStack(spacing: 0) {
                if todayTasks.isEmpty {
                    Label(
                        completedTodayTasks.isEmpty ? "Nothing planned yet" : "All caught up!",
                        systemImage: completedTodayTasks.isEmpty ? "tray" : "checkmark.seal.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                } else {
                    ForEach(Array(todayTasks.prefix(maxVisibleTasks).enumerated()), id: \.element.id) { index, task in
                        if index > 0 { Divider() }
                        taskRow(task)
                    }

                    if todayTasks.count > maxVisibleTasks {
                        Divider()
                        Button("+\(todayTasks.count - maxVisibleTasks) more") {
                            selectedTab = .tasks
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                    }
                }

                if !completedTodayTasks.isEmpty {
                    Divider()
                    DisclosureGroup(isExpanded: $showCompleted) {
                        ForEach(completedTodayTasks) { task in
                            taskRow(task)
                        }
                    } label: {
                        Text("Completed (\(completedTodayTasks.count))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func taskRow(_ task: FocusTask) -> some View {
        TaskRow(
            task: task,
            onToggle: {
                viewModel.toggleTask(task, context: context)
            },
            onEdit: {
                editingTask = task
            }
        )
        .contextMenu {
            Button {
                editingTask = task
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                withAnimation(listAnimation) {
                    viewModel.deleteTask(task, context: context)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .transition(.opacity)
    }

    // MARK: - Habits

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Today's Habits",
                actionTitle: "Manage",
                action: { selectedTab = .habits }
            )

            VStack(spacing: 0) {
                if habits.isEmpty {
                    Button {
                        selectedTab = .habits
                    } label: {
                        Label("No habits yet — add one", systemImage: "plus.circle")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                    }
                } else {
                    ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                        if index > 0 { Divider() }
                        CompactHabitRow(habit: habit) {
                            habitViewModel.toggleHabit(habit, context: context)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Focus shortcut

    private var focusShortcut: some View {
        Button {
            selectedTab = .focus
        } label: {
            Label("Start a focus session", systemImage: "timer")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.12))
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionHeader(
        title: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(actionTitle, action: action)
                .font(.subheadline)
        }
    }

    private var taskOptionsSheet: some View {
        NavigationStack {
            ScrollView {
                TaskInputView(
                    newTaskTitle: $newTaskTitle,
                    priority: $newTaskPriority,
                    dueDate: $newTaskDueDate,
                    category: $newTaskCategory
                ) {
                    viewModel.addTask(
                        title: newTaskTitle,
                        priority: newTaskPriority,
                        dueDate: newTaskDueDate,
                        category: newTaskCategory,
                        context: context
                    )
                    resetNewTaskFields()
                    showTaskOptions = false
                }
                .padding()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showTaskOptions = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func resetNewTaskFields() {
        newTaskTitle = ""
        newTaskPriority = .medium
        newTaskDueDate = Calendar.current.startOfDay(for: .now)
        newTaskCategory = .other
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
        .modelContainer(for: [FocusTask.self, Habit.self], inMemory: true)
}
