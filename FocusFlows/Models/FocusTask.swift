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

    var priority: TaskPriority {
        get {
            TaskPriority(rawValue: priorityRaw) ?? .medium
        }
        set {
            priorityRaw = newValue.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
    }
}
