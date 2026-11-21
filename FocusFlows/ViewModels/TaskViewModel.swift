import SwiftUI
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
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty else { return }

        tasks.append(
            FocusTask(
                title: trimmedTitle,
                isCompleted: false,
                priority: priority,
                dueDate: dueDate
            )
        )
    }

    func deleteTask(id: UUID) {
        let updatedTasks = tasks.filter { $0.id != id }
        tasks = updatedTasks
    }
    
    func updateTask(
        id: UUID,
        title: String,
        priority: TaskPriority,
        dueDate: Date?
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty else { return }

        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        tasks[index].title = trimmedTitle
        tasks[index].priority = priority
        tasks[index].dueDate = dueDate
    }
}
