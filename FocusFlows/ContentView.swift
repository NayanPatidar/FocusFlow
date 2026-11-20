import SwiftUI

struct ContentView: View {
    let taskName = "Read 10 pages"
    var isCompleted = false
    var completedTasks = 2
    let dailyTarget = 5
    
    @State private var counter = 1;
    
    func greetUser() {
        print("Welcome to Focus Flows")
    }
    
    struct Task: Identifiable {
        let id = UUID()
        let title: String
        var isCompleted: Bool
    }

    @State private var tasks = [
        Task(title: "Read 10 pages", isCompleted: false),
        Task(title: "Practice Swift", isCompleted: false),
        Task(title: "Go to the gym", isCompleted: true)
    ]
    
    var body: some View {
        VStack(spacing: 20) {

            HStack {
                Text("FocusFlow")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Text("My Profile")
                    .font(.headline)
            }
            
            HStack {
                Text("Text")
                    .font(.title3)
                
                Text("Habits")
                    .font(.title2)
            }
            .padding(.top, 30)


            Text("Build Better Habits")
                .font(.title3)

            Text("Let's get started!")
                .font(.subheadline)
            
            ForEach(tasks.indices, id: \.self) { index in
                Button {
                    tasks[index].isCompleted.toggle()
                } label: {
                    HStack {
                        Text(tasks[index].title)
                            .font(.title2)
                            .strikethrough(tasks[index].isCompleted)
                            .foregroundStyle(tasks[index].isCompleted ? .gray : .primary)

                        Spacer()

                        if tasks[index].isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            
            Text("Counter: \(counter)")
            Button("Increase") {
                counter += 1
            }
            Button("Decrease") {
                counter -= 1
            }
        }
        .onAppear{greetUser()}
        .padding(20)
    }
}

#Preview {
    ContentView()
}
