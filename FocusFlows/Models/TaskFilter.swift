import Foundation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    var id: String { rawValue }
}

enum TaskSort: String, CaseIterable, Identifiable {
    case none = "Default"
    case priority = "Priority"
    case dueDate = "Due Date"

    var id: String { rawValue }
}
