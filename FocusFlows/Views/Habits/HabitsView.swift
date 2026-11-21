import SwiftUI
import SwiftData

struct HabitsView: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \Habit.createdAt, order: .reverse)
    private var habits: [Habit]

    @State private var habitViewModel = HabitViewModel()
    @State private var newHabitName = ""
    @State private var editingHabit: Habit?

    @State private var newHabitReminderEnabled = false

    @State private var newHabitReminderTime = Calendar.current.date(
        bySettingHour: 9,
        minute: 0,
        second: 0,
        of: .now
    ) ?? .now

    private var completedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    private var progress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedCount) / Double(habits.count)
    }

    var body: some View {
        VStack(spacing: 20) {

            progressCard

            // MARK: - Add Habit

            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 12) {

                    TextField("Enter a habit", text: $newHabitName)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        addHabit()
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Toggle("Daily Reminder", isOn: $newHabitReminderEnabled)

                if newHabitReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $newHabitReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // MARK: - Habit List

            if habits.isEmpty {
                EmptyStateView(
                    systemImage: "repeat",
                    title: "No Habits Yet",
                    message: "Build consistency by adding your first daily habit."
                )
            } else {
                List {
                    ForEach(habits) { habit in
                        HabitRow(
                            habit: habit,
                            onToggle: {
                                habitViewModel.toggleHabit(
                                    habit,
                                    context: context
                                )
                            },
                            onEdit: {
                                editingHabit = habit
                            },
                            onDelete: {
                                habitViewModel.deleteHabit(
                                    habit,
                                    context: context
                                )
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .navigationTitle("Habits")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            habitViewModel.refreshDailyStatus(habits, context: context)
        }
        .sheet(item: $editingHabit) { habit in
            EditHabitView(habit: habit) { updatedName, updatedReminderTime in

                habit.name = updatedName
                habit.reminderTime = updatedReminderTime

                do {
                    try context.save()
                } catch {
                    print("Failed to update habit: \(error)")
                }

                if updatedReminderTime != nil {
                    Task {
                        let granted = await HabitReminderManager.shared
                            .requestNotificationPermission()

                        if granted {
                            HabitReminderManager.shared.scheduleReminder(for: habit)
                        } else {
                            print("[HabitReminder] Permission not granted")
                        }
                    }
                } else {
                    HabitReminderManager.shared.cancelReminder(for: habit)
                }
            }
        }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.headline)

                    Text("Keep your momentum going!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(completedCount)/\(habits.count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            ProgressView(value: progress)
                .tint(.green)

            Text("\(Int(progress * 100))% completed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Add Habit

    private func addHabit() {
        habitViewModel.addHabit(
            name: newHabitName,
            reminderTime: newHabitReminderEnabled ? newHabitReminderTime : nil,
            context: context
        )

        newHabitName = ""
        newHabitReminderEnabled = false
    }
}
