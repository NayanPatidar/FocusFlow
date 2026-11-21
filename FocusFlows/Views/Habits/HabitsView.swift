
import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]

    @State private var viewModel = HabitViewModel()
    @State private var newHabitName = ""
    @State private var editingHabit: Habit?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Habits")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Build consistency, one day at a time.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

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

            if habits.isEmpty {
                ContentUnavailableView(
                    "No Habits Yet",
                    systemImage: "repeat",
                    description: Text("Add your first habit to get started.")
                )
            } else {
                List {
                    ForEach(habits) { habit in
                        HabitRow(
                            habit: habit,
                            onToggle: {
                                viewModel.toggleHabit(habit, context: context)
                            },
                            onEdit: {
                                editingHabit = habit
                            },
                            onDelete: {
                                viewModel.deleteHabit(habit, context: context)
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
            viewModel.refreshDailyStatus(habits, context: context)
        }
        .sheet(item: $editingHabit) { habit in
            EditHabitView(habit: habit) { updatedName in
                habit.name = updatedName

                do {
                    try context.save()
                } catch {
                    print("Failed to update habit: \(error)")
                }
            }
        }
    }

    private func addHabit() {
        viewModel.addHabit(name: newHabitName, context: context)
        newHabitName = ""
    }
}
