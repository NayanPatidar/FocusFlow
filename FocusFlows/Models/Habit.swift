
import Foundation
import SwiftData

@Model
class Habit {
    var id: UUID
    var name: String
    var createdAt: Date
    var isCompletedToday: Bool
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        isCompletedToday: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.isCompletedToday = isCompletedToday
        self.completedAt = completedAt
    }
}
