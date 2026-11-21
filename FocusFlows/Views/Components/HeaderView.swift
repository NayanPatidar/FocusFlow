import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("FocusFlow")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Image(systemName: "person.circle")
                .font(.title2)
        }
    }
}
