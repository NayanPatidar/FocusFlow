import SwiftUI

struct QuickAddTaskBar: View {

    let onAdd: (String) -> Void
    let onShowOptions: () -> Void

    @State private var title = ""
    @FocusState private var isFocused: Bool

    private var canAdd: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField("Add a task for today", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(add)

            Button(action: onShowOptions) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More task options")

            Button(action: add) {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(canAdd ? Color.blue : Color.gray.opacity(0.4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .accessibilityLabel("Add task")
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func add() {
        guard canAdd else { return }
        onAdd(title)
        title = ""
        isFocused = false
    }
}
