import Foundation
import SwiftData

enum TaskPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}

@Model
class FocusTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var priorityRaw: String
    var dueDate: Date?
    var categoryRaw: String
    var completedAt: Date?

    var priority: TaskPriority {
        get {
            TaskPriority(rawValue: priorityRaw) ?? .medium
        }
        set {
            priorityRaw = newValue.rawValue
        }
    }

    var category: TaskCategory {
        get {
            TaskCategory(rawValue: categoryRaw) ?? .other
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        category: TaskCategory = .other,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.categoryRaw = category.rawValue
        self.completedAt = completedAt
    }
}
