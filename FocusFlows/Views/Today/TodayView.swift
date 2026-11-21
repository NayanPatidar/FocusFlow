import SwiftUI

struct TodayView: View {
    @State private var viewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    @State private var newTaskPriority: TaskPriority = .medium
    @State private var newTaskDueDate: Date?
    @State private var editingTask: FocusTask?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView()

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
                            Text("\(viewModel.completedTasks) of \(viewModel.totalTasks) tasks completed")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text(viewModel.totalTasks == 0
                                 ? "Start by adding your tasks"
                                 : "Keep up the good work!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chart.pie")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                    }

                    ProgressView(value: viewModel.progress)
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
                            dueDate: newTaskDueDate
                        )

                        newTaskTitle = ""
                        newTaskPriority = .medium
                        newTaskDueDate = nil
                    }

                    if viewModel.tasks.isEmpty {
                        ContentUnavailableView(
                            "No Tasks Yet",
                            systemImage: "checklist",
                            description: Text("Add a task to get started.")
                        )
                        .padding(.vertical, 20)
                    } else {
                        ForEach($viewModel.tasks) { $task in
                            TaskRow(task: $task) {
                                editingTask = task
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(id: task.id)
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
                    id: task.id,
                    title: updatedTitle,
                    priority: updatedPriority,
                    dueDate: updatedDueDate
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TodayView()
}
