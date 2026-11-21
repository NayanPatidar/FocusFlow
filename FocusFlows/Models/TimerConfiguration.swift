import Foundation

struct TimerConfiguration {
    var focusDuration: Int = 1
    var shortBreakDuration: Int = 5
    var longBreakDuration: Int = 10
    var sessionsBeforeLongBreak: Int = 4

    func duration(for phase: TimerPhase) -> TimeInterval {
        switch phase {
        case .focus:
            return TimeInterval(focusDuration * 60)
        case .shortBreak:
            return TimeInterval(shortBreakDuration)
        case .longBreak:
            return TimeInterval(longBreakDuration)
        }
    }
}
