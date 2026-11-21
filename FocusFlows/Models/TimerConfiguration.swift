
import Foundation

struct TimerConfiguration {

    private enum Keys {
        static let focus = "focusDuration"
        static let shortBreak = "shortBreakDuration"
        static let longBreak = "longBreakDuration"
        static let sessionsBeforeLongBreak = "sessionsBeforeLongBreak"
    }

    var focusDuration: Int {
        didSet {
            UserDefaults.standard.set(focusDuration, forKey: Keys.focus)
        }
    }

    var shortBreakDuration: Int {
        didSet {
            UserDefaults.standard.set(shortBreakDuration, forKey: Keys.shortBreak)
        }
    }

    var longBreakDuration: Int {
        didSet {
            UserDefaults.standard.set(longBreakDuration, forKey: Keys.longBreak)
        }
    }

    var sessionsBeforeLongBreak: Int {
        didSet {
            UserDefaults.standard.set(
                sessionsBeforeLongBreak,
                forKey: Keys.sessionsBeforeLongBreak
            )
        }
    }

    init() {
        let defaults = UserDefaults.standard

        focusDuration = defaults.object(forKey: Keys.focus) != nil
            ? defaults.integer(forKey: Keys.focus)
            : 25

        shortBreakDuration = defaults.object(forKey: Keys.shortBreak) != nil
            ? defaults.integer(forKey: Keys.shortBreak)
            : 5

        longBreakDuration = defaults.object(forKey: Keys.longBreak) != nil
            ? defaults.integer(forKey: Keys.longBreak)
            : 15

        sessionsBeforeLongBreak = defaults.object(
            forKey: Keys.sessionsBeforeLongBreak
        ) != nil
            ? defaults.integer(forKey: Keys.sessionsBeforeLongBreak)
            : 4
    }

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
