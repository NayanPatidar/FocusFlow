import SwiftUI
import SwiftData

struct TasksView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query private var tasks: [FocusTask]

    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .none

    @State private var showNewTask = false
    @State private var editingTask: FocusTask?
    @State private var showCompleted = false

    @State private var pendingDeleteTask: FocusTask?
    @State private var snackbarID: UUID?

    private let viewModel = TaskViewModel()

    // MARK: - Derived data

    private var visibleTasks: [FocusTask] {
        let filtered = viewModel.filteredTasks(
            tasks.filter { $0.id != pendingDeleteTask?.id },
            filter: selectedFilter,
            sort: selectedSort
        )

        guard !searchText.isEmpty else { return filtered }

        return filtered.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groups: [TaskGroup] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? .now

        var overdue: [FocusTask] = []
        var today: [FocusTask] = []
        var upcoming: [FocusTask] = []
        var noDate: [FocusTask] = []
        var completed: [FocusTask] = []

        for task in visibleTasks {
            if task.isCompleted {
                completed.append(task)
            } else if let due = task.dueDate {
                if due < startOfToday {
                    overdue.append(task)
                } else if due < startOfTomorrow {
                    today.append(task)
                } else {
                    upcoming.append(task)
                }
            } else {
                noDate.append(task)
            }
        }

        upcoming.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        completed.sort { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }

        return [
            TaskGroup(kind: .overdue, tasks: overdue),
            TaskGroup(kind: .today, tasks: today),
            TaskGroup(kind: .upcoming, tasks: upcoming),
            TaskGroup(kind: .noDate, tasks: noDate),
            TaskGroup(kind: .completed, tasks: completed)
        ]
        .filter { !$0.tasks.isEmpty }
    }

    private var isFilterActive: Bool {
        selectedFilter != .all || selectedSort != .none
    }

    private var listAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)
    }

    // MARK: - Body

    var body: some View {
        List {
            if selectedSort == .none {
                ForEach(groups) { group in
                    if group.kind == .completed {
                        Section(isExpanded: $showCompleted) {
                            rows(group.tasks)
                        } header: {
                            sectionHeader(group)
                        }
                    } else {
                        Section {
                            rows(group.tasks)
                        } header: {
                            sectionHeader(group)
                        }
                    }
                }
            } else {
                rows(visibleTasks)
            }
        }
        .listStyle(.sidebar)
        .overlay {
            if visibleTasks.isEmpty {
                emptyState
            }
        }
        .animation(listAnimation, value: visibleTasks.count)
        .navigationTitle("Tasks")
        .searchable(text: $searchText, prompt: "Search tasks")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                filterMenu
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewTask = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New task")
            }
        }
        .sheet(isPresented: $showNewTask) {
            NewTaskSheet { title, priority, dueDate, category in
                withAnimation(listAnimation) {
                    viewModel.addTask(
                        title: title,
                        priority: priority,
                        dueDate: dueDate,
                        category: category,
                        context: context
                    )
                }
            }
        }
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
        .overlay(alignment: .bottom) {
            if snackbarID != nil, pendingDeleteTask != nil {
                SnackbarView(
                    message: "Task deleted",
                    actionTitle: "UNDO",
                    onAction: undoDelete
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(listAnimation, value: snackbarID)
        .task(id: snackbarID) {
            // A new ID on every delete restarts the 4-second timer.
            guard snackbarID != nil else { return }

            do {
                try await Task.sleep(for: .seconds(4))
            } catch {
                return
            }

            commitPendingDelete()
        }
        .onDisappear(perform: commitPendingDelete)
    }

    // MARK: - Rows

    private func rows(_ tasks: [FocusTask]) -> some View {
        ForEach(tasks) { task in
            TaskRow(
                task: task,
                onToggle: {
                    viewModel.toggleTask(task, context: context)
                },
                onEdit: {
                    editingTask = task
                }
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    delete(task)
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Button {
                    editingTask = task
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.blue)
            }
            .contextMenu {
                Button {
                    editingTask = task
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    delete(task)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private func sectionHeader(_ group: TaskGroup) -> some View {
        HStack {
            Text(group.kind.title)
            Text("\(group.tasks.count)")
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(group.kind == .overdue ? .red : .primary)
    }

    // MARK: - Filter menu

    private var filterMenu: some View {
        Menu {
            Picker("Show", selection: $selectedFilter) {
                ForEach(TaskFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }

            Picker("Sort by", selection: $selectedSort) {
                ForEach(TaskSort.allCases) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            }

            if isFilterActive {
                Divider()
                Button("Reset") {
                    selectedFilter = .all
                    selectedSort = .none
                }
            }
        } label: {
            Image(systemName: isFilterActive
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("Filter and sort")
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyState: some View {
        if tasks.isEmpty {
            EmptyStateView(
                systemImage: "checklist",
                title: "No Tasks Yet",
                message: "Tap + to add your first task."
            )
        } else if !searchText.isEmpty {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "No Results Found",
                message: "Try a different search."
            )
        } else {
            EmptyStateView(
                systemImage: "line.3.horizontal.decrease.circle",
                title: "No Tasks Found",
                message: "No tasks match the selected filter."
            )
        }
    }

    // MARK: - Delete / Undo

    private func delete(_ task: FocusTask) {
        // Only one pending delete at a time: finish the previous one first.
        commitPendingDelete()

        viewModel.beginPendingDelete(task)

        withAnimation(listAnimation) {
            pendingDeleteTask = task
        }

        snackbarID = UUID()
    }

    private func undoDelete() {
        guard let task = pendingDeleteTask else { return }

        viewModel.cancelPendingDelete(task)

        withAnimation(listAnimation) {
            pendingDeleteTask = nil
        }

        snackbarID = nil
    }

    private func commitPendingDelete() {
        guard let task = pendingDeleteTask else { return }

        pendingDeleteTask = nil
        snackbarID = nil

        viewModel.deleteTask(task, context: context)
    }
}

// MARK: - Grouping

private struct TaskGroup: Identifiable {

    enum Kind {
        case overdue, today, upcoming, noDate, completed

        var title: String {
            switch self {
            case .overdue: return "Overdue"
            case .today: return "Today"
            case .upcoming: return "Upcoming"
            case .noDate: return "No Date"
            case .completed: return "Completed"
            }
        }
    }

    let kind: Kind
    let tasks: [FocusTask]

    var id: Kind { kind }
}
