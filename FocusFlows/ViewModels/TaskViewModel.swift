import Foundation
import Observation

@Observable
class TaskViewModel {
    var tasks: [FocusTask] = []

    var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }

    var totalTasks: Int {
        tasks.count
    }

    var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }

    func addTask(
        title: String,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }

        let task = FocusTask(
            title: trimmedTitle,
            priority: priority,
            dueDate: dueDate
        )

        tasks.append(task)
    }

    func deleteTask(id: UUID) {
        tasks = tasks.filter { $0.id != id }
    }

    func toggleTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        tasks[index].isCompleted.toggle()
    }

    func updateTask(
        id: UUID,
        title: String,
        priority: TaskPriority,
        dueDate: Date?
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        tasks[index].title = trimmedTitle
        tasks[index].priority = priority
        tasks[index].dueDate = dueDate
    }

    func filteredTasks(
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
}
