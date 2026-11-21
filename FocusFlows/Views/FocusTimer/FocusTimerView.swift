
import SwiftUI
import SwiftData

struct FocusTimerView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel = TimerViewModel()
    @State private var showSettings = false

    var body: some View {

        VStack(spacing: 32) {

            header

            phaseSelector

            timerCircle

            sessionInfo

            controls
        }
        .padding()
        .navigationTitle("Focus Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            viewModel.updateConfiguration()
        }) {
            NavigationStack {
                TimerSettingsView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refreshTimer()
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(spacing: 8) {

            Text("Stay focused.")
                .font(.title2)
                .fontWeight(.bold)

            Text("One task at a time.")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Phase Selector

    private var phaseSelector: some View {

        HStack(spacing: 8) {

            ForEach(TimerPhase.allCases) { phase in

                Button {
                    viewModel.changePhase(to: phase)
                } label: {

                    Text(phase.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.currentPhase == phase
                            ? Color.blue
                            : Color(.secondarySystemBackground)
                        )
                        .foregroundStyle(
                            viewModel.currentPhase == phase
                            ? .white
                            : .primary
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Timer Circle

    private var timerCircle: some View {

        ZStack {

            Circle()
                .stroke(
                    Color.gray.opacity(0.15),
                    lineWidth: 18
                )

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    Color.blue.gradient,
                    style: StrokeStyle(
                        lineWidth: 18,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: viewModel.progress)

            VStack(spacing: 8) {

                Text(viewModel.currentPhase.rawValue)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(viewModel.formattedTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text(viewModel.isRunning ? "In progress" : "Ready")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 280, height: 280)
    }

    // MARK: - Session Info

    private var sessionInfo: some View {

        HStack(spacing: 12) {

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text("Focus sessions completed")

            Spacer()

            Text("\(viewModel.completedFocusSessions)")
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                .background(Color.blue)
                .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        FocusTimerView()
    }
}
