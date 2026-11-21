import SwiftData
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

    @ObservationIgnored
    private var modelContext: ModelContext?

    @ObservationIgnored
    private var focusStartedAt: Date?

    init() {
        remainingSeconds = configuration.duration(for: currentPhase)
    }

    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    // MARK: - Configuration

    func updateConfiguration() {
        configuration = TimerConfiguration()

        if !isRunning {
            remainingSeconds = configuration.duration(for: currentPhase)
        }
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

        if currentPhase == .focus && focusStartedAt == nil {
            focusStartedAt = Date()
        }

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }

        Task {
            await NotificationManager.shared.requestPermission()

            NotificationManager.shared.scheduleNotification(
                title: "\(currentPhase.rawValue) Complete",
                body: notificationMessage(for: currentPhase),
                after: remainingSeconds
            )
        }
    }

    // MARK: - Pause

    func pause() {
        timer?.invalidate()
        timer = nil

        NotificationManager.shared.cancelNotification()

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

        NotificationManager.shared.cancelNotification()

        isRunning = false
        endDate = nil

        let completedPhase = currentPhase

        // Save completed focus session
        if completedPhase == .focus {

            let startedAt = focusStartedAt
                ?? Date().addingTimeInterval(-configuration.duration(for: .focus))

            let completedAt = Date()

            let session = FocusSession(
                startedAt: startedAt,
                completedAt: completedAt,
                duration: completedAt.timeIntervalSince(startedAt)
            )

            modelContext?.insert(session)

            do {
                try modelContext?.save()
                print("[FocusSession] Saved successfully")
            } catch {
                print("[FocusSession] Save failed: \(error)")
            }

            focusStartedAt = nil
        }

        // Feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        AudioServicesPlaySystemSound(1005)

        // Determine next phase
        if completedPhase == .focus {

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

    // MARK: - Notification Message

    private func notificationMessage(for phase: TimerPhase) -> String {
        switch phase {

        case .focus:
            return "Your focus session is complete. Time for a break!"

        case .shortBreak:
            return "Your short break is over. Ready to focus again?"

        case .longBreak:
            return "Your long break is over. Let's get back to work!"
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
