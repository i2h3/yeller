import SwiftUI

struct AssistantAvatar: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.secondary)
                .frame(width: size, height: size)

            Image(systemName: "sparkles")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
