import SwiftUI

struct FocusButton: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(title) {
            action()
        }
        .font(.headline)
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
