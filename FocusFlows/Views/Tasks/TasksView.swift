
import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [FocusTask]

    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .none

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
                }
                .onDelete { offsets in
                    let tasksToDelete = offsets.map {
                        searchedTasks[$0]
                    }

                    viewModel.deleteTasks(tasksToDelete, context: context)
                }
            }
        }
        .navigationTitle("Tasks")
    }
}
