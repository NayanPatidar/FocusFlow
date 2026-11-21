import SwiftUI
import SwiftData

struct FocusTimerView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query(sort: \FocusSession.completedAt, order: .reverse)
    private var focusSessions: [FocusSession]

    @State private var viewModel = TimerViewModel()
    @State private var showSettings = false

    // MARK: - Derived data

    private var sessionsToday: [FocusSession] {
        focusSessions.filter { Calendar.current.isDateInToday($0.completedAt) }
    }

    private var focusTimeToday: TimeInterval {
        sessionsToday.reduce(0) { $0 + $1.duration }
    }

    private var phaseColor: Color {
        switch viewModel.currentPhase {
        case .focus: return .blue
        case .shortBreak: return .green
        case .longBreak: return .teal
        }
    }

    /// Position in the current cycle toward the long break (e.g. 2 of 4).
    private var cyclePosition: Int {
        let perCycle = max(1, viewModel.configuration.sessionsBeforeLongBreak)
        return viewModel.completedFocusSessions % perCycle
    }

    private var phaseBinding: Binding<TimerPhase> {
        Binding(
            get: { viewModel.currentPhase },
            set: { viewModel.changePhase(to: $0) }
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 28) {

            Picker("Phase", selection: phaseBinding) {
                ForEach(TimerPhase.allCases) { phase in
                    Text(phase.rawValue).tag(phase)
                }
            }
            .pickerStyle(.segmented)

            Spacer(minLength: 0)

            timerCircle

            cycleDots

            Spacer(minLength: 0)

            controls

            todaySummary
        }
        .padding()
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: viewModel.currentPhase)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.isRunning)
        .navigationTitle("Focus")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Timer settings")
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            viewModel.updateConfiguration()
        }) {
            NavigationStack {
                TimerSettingsView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showSettings = false
                            }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refreshTimer()
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            // Durations may have been changed from Settings.
            viewModel.updateConfiguration()
        }
    }

    // MARK: - Timer Circle

    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(phaseColor.opacity(0.15), lineWidth: 18)

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    phaseColor.gradient,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut, value: viewModel.progress)

            VStack(spacing: 6) {
                Text(viewModel.currentPhase.rawValue)
                    .font(.headline)
                    .foregroundStyle(phaseColor)
                    .contentTransition(.opacity)

                Text(viewModel.formattedTime)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(viewModel.isRunning ? "In progress" : "Ready")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: 280, maxHeight: 280)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(viewModel.currentPhase.rawValue), \(viewModel.formattedTime) remaining")
        .accessibilityValue(viewModel.isRunning ? "Running" : "Paused")
    }

    // MARK: - Cycle dots

    private var cycleDots: some View {
        let total = max(1, viewModel.configuration.sessionsBeforeLongBreak)

        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < cyclePosition ? phaseColor : Color(.systemGray4))
                        .frame(width: 10, height: 10)
                }
            }

            Text("\(cyclePosition) of \(total) until long break")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(cyclePosition) of \(total) focus sessions until long break")
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Reset timer")

            Button {
                if viewModel.isRunning {
                    viewModel.pause()
                } else {
                    viewModel.start()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    Text(viewModel.isRunning ? "Pause" : "Start")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(phaseColor)
                .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today summary

    private var todaySummary: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text("Today")
                .font(.subheadline.weight(.semibold))

            Spacer()

            Text("\(sessionsToday.count) \(sessionsToday.count == 1 ? "session" : "sessions") · \(formatDuration(focusTimeToday))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

#Preview {
    NavigationStack {
        FocusTimerView()
    }
    .modelContainer(for: FocusSession.self, inMemory: true)
}
