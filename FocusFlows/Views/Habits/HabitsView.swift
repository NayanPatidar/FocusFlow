import SwiftUI
import SwiftData

struct HabitsView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query(sort: \Habit.createdAt, order: .reverse)
    private var allHabits: [Habit]

    /// Habits on screen, without one that is waiting to be deleted.
    private var habits: [Habit] {
        allHabits.filter { $0.id != pendingDeleteHabit?.id }
    }

    @State private var habitViewModel = HabitViewModel()
    @State private var editingHabit: Habit?
    @State private var showNewHabit = false

    @State private var pendingDeleteHabit: Habit?
    @State private var snackbarID: UUID?

    private var completedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    private var progress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedCount) / Double(habits.count)
    }

    private var listAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)
    }

    // MARK: - Body

    var body: some View {
        List {
            if !habits.isEmpty {
                progressHeader
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(habits) { habit in
                HabitRow(
                    habit: habit,
                    onToggle: {
                        habitViewModel.toggleHabit(habit, context: context)
                    },
                    onEdit: {
                        editingHabit = habit
                    },
                    onDelete: {
                        delete(habit)
                    }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        delete(habit)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        editingHabit = habit
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if habits.isEmpty {
                EmptyStateView(
                    systemImage: "repeat",
                    title: "No Habits Yet",
                    message: "Tap + to start building a daily habit."
                )
            }
        }
        .animation(listAnimation, value: habits.count)
        .navigationTitle("Habits")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewHabit = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New habit")
            }
        }
        .onAppear {
            habitViewModel.refreshDailyStatus(allHabits, context: context)
        }
        .sheet(isPresented: $showNewHabit) {
            NewHabitSheet { name, reminderTime in
                withAnimation(listAnimation) {
                    habitViewModel.addHabit(
                        name: name,
                        reminderTime: reminderTime,
                        context: context
                    )
                }
            }
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
        .overlay(alignment: .bottom) {
            if snackbarID != nil, pendingDeleteHabit != nil {
                SnackbarView(
                    message: "Habit deleted",
                    actionTitle: "UNDO",
                    onAction: undoDelete
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(listAnimation, value: snackbarID)
        .task(id: snackbarID) {
            guard snackbarID != nil else { return }

            do {
                try await Task.sleep(for: .seconds(4))
            } catch {
                return
            }

            commitPendingDelete()
        }
        .onDisappear(perform: commitPendingDelete)
    }

    // MARK: - Progress header

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(completedCount == habits.count ? "All habits done today 🎉" : "Today")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(completedCount) of \(habits.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            ProgressView(value: progress)
                .tint(.green)
                .animation(listAnimation, value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(completedCount) of \(habits.count) habits done today")
    }

    // MARK: - Delete / Undo

    private func delete(_ habit: Habit) {
        // Only one pending delete at a time: finish the previous one first.
        commitPendingDelete()

        habitViewModel.beginPendingDelete(habit)

        withAnimation(listAnimation) {
            pendingDeleteHabit = habit
        }

        snackbarID = UUID()
    }

    private func undoDelete() {
        guard let habit = pendingDeleteHabit else { return }

        habitViewModel.cancelPendingDelete(habit)

        withAnimation(listAnimation) {
            pendingDeleteHabit = nil
        }

        snackbarID = nil
    }

    private func commitPendingDelete() {
        guard let habit = pendingDeleteHabit else { return }

        pendingDeleteHabit = nil
        snackbarID = nil

        habitViewModel.deleteHabit(habit, context: context)
    }
}
