import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [FocusTask]

    @State private var viewModel = TaskViewModel()

    @State private var newTaskTitle = ""
    @State private var newTaskPriority: TaskPriority = .medium
    @State private var newTaskDueDate: Date?

    @State private var editingTask: FocusTask?
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .none

    private var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasks) / Double(tasks.count)
    }

    private var displayedTasks: [FocusTask] {
        viewModel.filteredTasks(
            tasks,
            filter: selectedFilter,
            sort: selectedSort
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView()

                // Greeting
                VStack(alignment: .leading, spacing: 8) {
                    Text(Date.now.formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Good morning!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Let's make today count.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Progress
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Progress")
                        .font(.headline)

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(completedTasks) of \(tasks.count) tasks completed")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text(
                                tasks.isEmpty
                                    ? "Start by adding your tasks"
                                    : "Keep up the good work!"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chart.pie")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                    }

                    ProgressView(value: progress)
                        .tint(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Tasks
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Tasks")
                        .font(.title2)
                        .fontWeight(.bold)

                    TaskInputView(
                        newTaskTitle: $newTaskTitle,
                        priority: $newTaskPriority,
                        dueDate: $newTaskDueDate
                    ) {
                        viewModel.addTask(
                            title: newTaskTitle,
                            priority: newTaskPriority,
                            dueDate: newTaskDueDate,
                            context: context
                        )

                        newTaskTitle = ""
                        newTaskPriority = .medium
                        newTaskDueDate = nil
                    }

                    // Filter
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(TaskFilter.allCases) { filter in
                            Text(filter.rawValue)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Sort
                    Picker("Sort", selection: $selectedSort) {
                        ForEach(TaskSort.allCases) { sort in
                            Text(sort.rawValue)
                                .tag(sort)
                        }
                    }
                    .pickerStyle(.menu)

                    // Task List
                    if displayedTasks.isEmpty {
                        ContentUnavailableView(
                            emptyTitle,
                            systemImage: "checklist",
                            description: Text(
                                "Tasks matching this filter will appear here."
                            )
                        )
                        .padding(.vertical, 20)
                    } else {
                        ForEach(displayedTasks) { task in
                            TaskRow(
                                task: task,
                                onToggle: {
                                    viewModel.toggleTask(task, context: context)
                                },
                                onEdit: {
                                    editingTask = task
                                }
                            )
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(task, context: context)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(item: $editingTask) { task in
            EditTaskView(task: task) { updatedTitle, updatedPriority, updatedDueDate in
                viewModel.updateTask(
                    task,
                    title: updatedTitle,
                    priority: updatedPriority,
                    dueDate: updatedDueDate,
                    context: context
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyTitle: String {
        switch selectedFilter {
        case .all:
            return "No Tasks Yet"
        case .active:
            return "No Active Tasks"
        case .completed:
            return "No Completed Tasks"
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: FocusTask.self, inMemory: true)
}
