
import Foundation
import Observation
import SwiftData

@Observable
class TaskViewModel {

    // MARK: - Add Task

    func addTask(
        title: String,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        category: TaskCategory = .other,
        context: ModelContext
    ) {

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }

        let task = FocusTask(
            title: trimmedTitle,
            priority: priority,
            dueDate: dueDate,
            category: category
        )

        context.insert(task)
        save(context)

        TaskReminderManager.shared.scheduleReminder(for: task)
        
        TaskReminderManager.shared.requestNotificationPermission()
    }

    // MARK: - Delete Task

    func deleteTask(
        _ task: FocusTask,
        context: ModelContext
    ) {

        TaskReminderManager.shared.cancelReminder(for: task)

        context.delete(task)
        save(context)
    }

    // MARK: - Bulk Delete

    func deleteTasks(
        _ tasks: [FocusTask],
        context: ModelContext
    ) {

        for task in tasks {
            TaskReminderManager.shared.cancelReminder(for: task)
            context.delete(task)
        }

        save(context)
    }

    // MARK: - Toggle Task

    func toggleTask(
        _ task: FocusTask,
        context: ModelContext
    ) {

        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? .now : nil

        if task.isCompleted {
            TaskReminderManager.shared.cancelReminder(for: task)
        } else {
            TaskReminderManager.shared.scheduleReminder(for: task)
        }

        save(context)
    }

    // MARK: - Update Task

    func updateTask(
        _ task: FocusTask,
        title: String,
        priority: TaskPriority,
        dueDate: Date?,
        category: TaskCategory,
        context: ModelContext
    ) {

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }

        task.title = trimmedTitle
        task.priority = priority
        task.dueDate = dueDate
        task.category = category

        TaskReminderManager.shared.scheduleReminder(for: task)

        save(context)
    }

    // MARK: - Filtering & Sorting

    func filteredTasks(
        _ tasks: [FocusTask],
        filter: TaskFilter,
        sort: TaskSort
    ) -> [FocusTask] {

        var result = tasks

        // Filtering
        switch filter {

        case .all:
            break

        case .active:
            result = result.filter { !$0.isCompleted }

        case .completed:
            result = result.filter { $0.isCompleted }
        }

        // Sorting
        switch sort {

        case .none:
            break

        case .priority:
            result.sort {
                priorityRank($0.priority) > priorityRank($1.priority)
            }

        case .dueDate:
            result.sort {

                switch ($0.dueDate, $1.dueDate) {

                case let (lhs?, rhs?):
                    return lhs < rhs

                case (_?, nil):
                    return true

                case (nil, _?):
                    return false

                case (nil, nil):
                    return false
                }
            }
        }

        return result
    }

    // MARK: - Priority Ranking

    private func priorityRank(_ priority: TaskPriority) -> Int {

        switch priority {

        case .low:
            return 1

        case .medium:
            return 2

        case .high:
            return 3
        }
    }

    // MARK: - Save

    private func save(_ context: ModelContext) {

        do {
            try context.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}
