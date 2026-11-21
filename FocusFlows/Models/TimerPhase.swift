import Foundation

enum TimerPhase: String, CaseIterable, Identifiable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var id: String {
        rawValue
    }

    var duration: TimeInterval {
        switch self {
        case .focus:
            return 25 * 60
        case .shortBreak:
            return 5 * 60
        case .longBreak:
            return 15 * 60
        }
    }
}
