import Foundation

struct FocusTask: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}
