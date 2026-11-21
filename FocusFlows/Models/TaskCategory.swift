import Foundation

enum TaskCategory: String, CaseIterable, Identifiable {
    case work = "Work"
    case study = "Study"
    case personal = "Personal"
    case health = "Health"
    case other = "Other"

    var id: String { rawValue }
}
