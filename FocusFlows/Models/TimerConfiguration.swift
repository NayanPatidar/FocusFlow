
import Foundation

struct TimerConfiguration {
    var focusDuration: Int = 25
    var shortBreakDuration: Int = 5
    var longBreakDuration: Int = 15
    var sessionsBeforeLongBreak: Int = 4

    func duration(for phase: TimerPhase) -> TimeInterval {
        switch phase {
        case .focus:
            return TimeInterval(focusDuration * 60)
        case .shortBreak:
            return TimeInterval(shortBreakDuration * 60)
        case .longBreak:
            return TimeInterval(longBreakDuration * 60)
        }
    }
}
