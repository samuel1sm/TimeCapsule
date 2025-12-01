import SwiftUI

struct RoundButtonView: View {
	var action: () -> Void
	var systemImageName: String = "plus"

	var iconScale: CGFloat = 0.5
	@State private var containerSize: CGSize = .zero

	var body: some View {
		Button(action: action) {
			ZStack {
				Circle()
					.fill(
						LinearGradient(
							colors: [Color.pink, Color.purple],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					)

				let d = min(containerSize.width, containerSize.height)
				Image(systemName: systemImageName)
					.font(.system(size: max(1, d * iconScale), weight: .semibold))
					.foregroundStyle(.white)
			}
			.aspectRatio(1, contentMode: .fit)
			.readSize($containerSize)
		}
		.frame(idealWidth: 56, idealHeight: 56)
		.contentShape(Circle())
	}
}

#Preview {
	VStack(spacing: 24) {
		// Uses ideal size (56x56)
		RoundButtonView { }

		// Scales automatically to the parent frame (100x100)
		RoundButtonView(action: {}, systemImageName: "pencil")
	}
	.padding()
}
