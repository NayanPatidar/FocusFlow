import SwiftUI

struct ContentView: View {

    let taskName = "Read 10 pages"
    var isCompleted = false
    var completedTasks = 2
    let dailyTarget = 5

    @State private var counter = 1
    @State private var newTaskTitle = ""
    @FocusState private var isTaskFieldFocused: Bool

    func greetUser() {
        print("Welcome to Focus Flows")
    }

    @State private var tasks = [
        FocusTask(title: "Read 10 pages", isCompleted: false),
        FocusTask(title: "Practice Swift", isCompleted: false),
        FocusTask(title: "Go to the gym", isCompleted: true)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                HStack {
                    Text("FocusFlow")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Text("My Profile")
                        .font(.headline)
                }.frame(maxWidth: .infinity, minHeight: 60)
                
                HStack {
                    Text("Text")
                        .font(.title3)
                    
                    Text("Habits")
                        .font(.title2)
                }
                .padding(.top, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.orange)

                        Text("Build Better Habits")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Text("Let's get started!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                
                TextField("Enter a task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTaskFieldFocused)
                    .padding(.horizontal)
                
                if tasks.isEmpty {
                    Text("No tasks yet")
                } else {
                    ForEach(tasks.indices, id: \.self) { index in
                        TaskRow(task: $tasks[index])
                    }
                }
                
                FocusButton(title: "Add Task") {
                    if !newTaskTitle.isEmpty {
                        tasks.append(
                            FocusTask(title: newTaskTitle, isCompleted: false)
                        )

                        newTaskTitle = ""
                        isTaskFieldFocused = false
                    }
                }

                FocusButton(title: "Add Habit") {
                    print("Adding a habit")
                }

                FocusButton(title: "Start Focus") {
                    print("Starting focus session")
                }
                
                Text("Counter: \(counter)")
                
                FocusButton(title: "Increase Counter") {
                    counter += 1
                }
                
                FocusButton(title: "Decrease Counter") {
                    counter -= 1
                }
            }
            .onAppear {
                greetUser()
            }
            .padding(20)
        }
    }
}

#Preview {
    ContentView()
}
