import SwiftUI

struct ContentView: View {

    let taskName = "Read 10 pages"
    var isCompleted = false
    var completedTasks = 2
    let dailyTarget = 5

    @State private var counter = 1

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
                
                VStack {
                    Text("Build Better Habits")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Let's get started!")
                        .font(.subheadline)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                
                ForEach(tasks.indices, id: \.self) { index in
                    TaskRow(task: $tasks[index])
                }
                
                Text("Counter: \(counter)")
                
                Button("Increase") {
                    counter += 1
                }
                
                Button("Decrease") {
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
