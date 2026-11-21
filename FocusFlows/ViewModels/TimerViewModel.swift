
import Foundation
import Observation
import UIKit
import AudioToolbox

@Observable
class TimerViewModel {

    var currentPhase: TimerPhase = .focus
    var remainingSeconds: TimeInterval = 25 * 60
    var isRunning = false
    var completedFocusSessions = 0
    var configuration = TimerConfiguration()

    @ObservationIgnored
    private var timer: Timer?

    @ObservationIgnored
    private var endDate: Date?

    init() {
        remainingSeconds = configuration.duration(for: currentPhase)
    }
    
    // MARK: - Refresh
    
    func refreshTimer() {
        guard isRunning, let endDate else { return }

        remainingSeconds = max(0, endDate.timeIntervalSinceNow)

        if remainingSeconds <= 0 {
            completePhase()
        }
    }

    // MARK: - Start

    func start() {
        guard !isRunning else { return }

        isRunning = true
        endDate = Date().addingTimeInterval(remainingSeconds)

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }

    // MARK: - Pause

    func pause() {
        timer?.invalidate()
        timer = nil

        if let endDate {
            remainingSeconds = max(0, endDate.timeIntervalSinceNow)
        }

        isRunning = false
        self.endDate = nil
    }

    // MARK: - Reset

    func reset() {
        pause()
        remainingSeconds = configuration.duration(for: currentPhase)
    }

    // MARK: - Tick

    private func tick() {
        guard let endDate else { return }

        remainingSeconds = max(0, endDate.timeIntervalSinceNow)

        if remainingSeconds <= 0 {
            completePhase()
        }
    }

    // MARK: - Phase Completion

    private func completePhase() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        endDate = nil

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        AudioServicesPlaySystemSound(1005)

        if currentPhase == .focus {
            completedFocusSessions += 1

            if completedFocusSessions % configuration.sessionsBeforeLongBreak == 0 {
                currentPhase = .longBreak
            } else {
                currentPhase = .shortBreak
            }
        } else {
            currentPhase = .focus
        }

        remainingSeconds = configuration.duration(for: currentPhase)
        start()
    }

    // MARK: - Change Phase

    func changePhase(to phase: TimerPhase) {
        guard currentPhase != phase else { return }

        let wasRunning = isRunning

        pause()

        currentPhase = phase
        remainingSeconds = configuration.duration(for: phase)

        if wasRunning {
            start()
        }
    }

    // MARK: - Time Formatting

    var formattedTime: String {
        let totalSeconds = Int(remainingSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Progress

    var progress: Double {
        let totalDuration = configuration.duration(for: currentPhase)

        guard totalDuration > 0 else { return 0 }

        return 1 - (remainingSeconds / totalDuration)
    }
}
