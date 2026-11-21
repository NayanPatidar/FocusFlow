import SwiftUI

struct TasksView: View {
    var body: some View {
        VStack {
            Text("Tasks")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle("Tasks")
    }
}
