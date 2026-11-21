import Foundation

enum TaskPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}

struct FocusTask: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var priority: TaskPriority = .medium
    var dueDate: Date? = nil
}
