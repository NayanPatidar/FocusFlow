import SwiftUI

struct TimerSettingsView: View {

    @AppStorage("focusDuration") private var focusDuration = 25
    @AppStorage("shortBreakDuration") private var shortBreakDuration = 5
    @AppStorage("longBreakDuration") private var longBreakDuration = 15
    @AppStorage("sessionsBeforeLongBreak") private var sessionsBeforeLongBreak = 4

    var body: some View {

        Form {

            Section("Focus Duration") {

                durationControl(
                    title: "Focus",
                    value: $focusDuration,
                    range: 5...90,
                    unit: "min"
                )
            }

            Section("Break Durations") {

                durationControl(
                    title: "Short Break",
                    value: $shortBreakDuration,
                    range: 1...30,
                    unit: "min"
                )

                durationControl(
                    title: "Long Break",
                    value: $longBreakDuration,
                    range: 5...60,
                    unit: "min"
                )
            }

            Section("Focus Cycle") {

                Stepper(
                    "Sessions before long break: \(sessionsBeforeLongBreak)",
                    value: $sessionsBeforeLongBreak,
                    in: 2...10
                )
            }

            Section {

                Text("Your timer preferences are saved automatically.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Timer Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func durationControl(
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Text(title)

                Spacer()

                Text("\(value.wrappedValue) \(unit)")
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            Slider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Int($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        TimerSettingsView()
    }
}
