
import Foundation
import SwiftData

@Model
class FocusSession {

    var id: UUID
    var startedAt: Date
    var completedAt: Date
    var duration: TimeInterval

    init(
        startedAt: Date,
        completedAt: Date,
        duration: TimeInterval
    ) {
        self.id = UUID()
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
    }
}
