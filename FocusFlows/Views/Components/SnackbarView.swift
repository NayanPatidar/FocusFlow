import SwiftUI

struct SnackbarView: View {
    let message: String
    let actionTitle: String
    let onAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text(message)
                .foregroundStyle(.white)
                .font(.subheadline)

            Spacer(minLength: 8)

            Button(actionTitle, action: onAction)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemGray6).opacity(0.15))
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}
