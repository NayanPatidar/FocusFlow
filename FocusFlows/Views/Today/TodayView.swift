import SwiftUI
import SwiftData
import UserNotifications

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [FocusTask]
    @Query private var habits: [Habit]

    @State private var viewModel = TaskViewModel()
    @State private var habitViewModel = HabitViewModel()

    @State private var newTaskTitle = ""
    @State private var newTaskPriority: TaskPriority = .medium
    @State private var newTaskDueDate: Date?
    @State private var newTaskCategory: TaskCategory = .other

    @State private var editingTask: FocusTask?
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .none
    
    private var completedTaskCount: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var taskProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTaskCount) / Double(tasks.count)
    }

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
    
    private func printPendingReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("---- Pending Notifications ----")

            for request in requests {
                print("ID: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                print("Trigger: \(String(describing: request.trigger))")
            }

            print("-----------------------------")
        }
    }
    
    private var taskProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Task Progress")
                        .font(.headline)

                    Text("Keep moving forward.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(completedTaskCount)/\(tasks.count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            ProgressView(value: taskProgress)
                .tint(.blue)

            Text("\(Int(taskProgress * 100))% completed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var todayTasks: [FocusTask] {
        tasks.filter { !$0.isCompleted }
    }
    
    private var todayHabits: [Habit] {
        habits
    }
    
    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("\(todayTasks.count) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if todayTasks.isEmpty {
                ContentUnavailableView(
                    "All Caught Up!",
                    systemImage: "checkmark.circle.fill",
                    description: Text("You've completed all your tasks.")
                )
            } else {
                ForEach(todayTasks) { task in
                    TaskRow(
                        task: task,
                        onToggle: {
                            viewModel.toggleTask(task, context: context)
                        },
                        onEdit: {
                            editingTask = task
                        }
                    )
                }
            }
        }
    }
    
    private var habitsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Habits")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if todayHabits.isEmpty {
                ContentUnavailableView(
                    "No Habits Yet",
                    systemImage: "repeat",
                    description: Text("Create habits to build your daily routine.")
                )
            } else {
                ForEach(todayHabits) { habit in
                    HabitRow(
                        habit: habit,
                        onToggle: {
                            habitViewModel.toggleHabit(habit, context: context)
                        },
                        onEdit: {
                            // No editing action on the dashboard for now.
                        },
                        onDelete: {
                            // No deletion action on the dashboard for now.
                        }
                    )
                }
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView()
                taskProgressCard
                todayTasksSection
                habitsPreviewSection

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

                            Text(tasks.isEmpty
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

                        newTaskTitle = ""
                        newTaskPriority = .medium
                        newTaskDueDate = nil
                        newTaskCategory = .other
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

                    // Task list
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
        .onAppear {
            habitViewModel.refreshDailyStatus(habits, context: context)
            printPendingReminders()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyTitle: String {
        switch selectedFilter {
        case .all: return "No Tasks Yet"
        case .active: return "No Active Tasks"
        case .completed: return "No Completed Tasks"
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: FocusTask.self, inMemory: true)
}
