import SwiftUI
import SwiftData

struct TasksView: View {

    @Environment(\.modelContext) private var context
    @Query private var tasks: [FocusTask]

    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .none
    @State private var deletedTask: FocusTask?
    @State private var showSnackbar = false

    private let viewModel = TaskViewModel()

    private var searchedTasks: [FocusTask] {
        let filtered = viewModel.filteredTasks(
            tasks,
            filter: selectedFilter,
            sort: selectedSort
        )

        if searchText.isEmpty {
            return filtered
        }

        return filtered.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var emptyState: some View {
        if tasks.isEmpty {
            EmptyStateView(
                systemImage: "checklist",
                title: "No Tasks Yet",
                message: "Start organizing your day by adding your first task."
            )
        } else if !searchText.isEmpty {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "No Results Found",
                message: "Try changing your search to find the task you're looking for."
            )
        } else {
            EmptyStateView(
                systemImage: "line.3.horizontal.decrease.circle",
                title: "No Tasks Found",
                message: "No tasks match the selected filter."
            )
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            TextField("Search tasks...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Picker("Filter", selection: $selectedFilter) {
                ForEach(TaskFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Picker("Sort", selection: $selectedSort) {
                ForEach(TaskSort.allCases) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            List {
                if searchedTasks.isEmpty {
                    emptyState
                } else {
                    ForEach(searchedTasks) { task in
                        TaskRow(
                            task: task,
                            onToggle: {
                                viewModel.toggleTask(task, context: context)
                            },
                            onEdit: {
                                // Edit action handled by TaskRow
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deletedTask = task

                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    viewModel.deleteTask(task, context: context)
                                }

                                showSnackbar = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        let tasksToDelete = offsets.map {
                            searchedTasks[$0]
                        }

                        guard let task = tasksToDelete.first, tasksToDelete.count == 1 else {
                            viewModel.deleteTasks(tasksToDelete, context: context)
                            return
                        }

                        deletedTask = task

                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.deleteTask(task, context: context)
                        }

                        showSnackbar = true
                    }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: searchedTasks.count)
        }
        .navigationTitle("Tasks")
        .overlay(alignment: .bottom) {
            if showSnackbar, let deletedTask {
                SnackbarView(
                    message: "Task deleted",
                    actionTitle: "UNDO"
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.restoreTask(deletedTask, context: context)
                    }

                    showSnackbar = false
                    self.deletedTask = nil
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showSnackbar)
        .task(id: showSnackbar) {
            guard showSnackbar else { return }

            do {
                try await Task.sleep(for: .seconds(4))
            } catch {
                return
            }

            showSnackbar = false
            deletedTask = nil
        }
    }
}
