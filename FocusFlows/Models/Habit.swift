import Foundation
import SwiftData

@Model
class Habit {

    var id: UUID
    var name: String
    var createdAt: Date
    var isCompletedToday: Bool
    var completedAt: Date?
    var completionDatesData: Data

    // Optional daily reminder time
    var reminderTime: Date?

    var completionDates: [Date] {
        get {
            (try? JSONDecoder().decode(
                [Date].self,
                from: completionDatesData
            )) ?? []
        }
        set {
            completionDatesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        isCompletedToday: Bool = false,
        completedAt: Date? = nil,
        completionDates: [Date] = [],
        reminderTime: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.isCompletedToday = isCompletedToday
        self.completedAt = completedAt
        self.completionDatesData = (try? JSONEncoder().encode(completionDates)) ?? Data()
        self.reminderTime = reminderTime
    }
}
