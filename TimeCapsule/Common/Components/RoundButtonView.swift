import SwiftUI

struct RoundButtonView: View {
	
	var systemImageName: String = "plus"
	var colors: [Color] = .pinkGradient
	var iconScale: CGFloat = 0.5
	var action: () -> Void
	@State private var containerSize: CGSize = .zero

	var body: some View {
		Button(action: action) {
			ZStack {
				Circle()
					.fill(
						LinearGradient(
							colors: colors,
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					)

				let d = min(containerSize.width, containerSize.height)
				Image(systemName: systemImageName)
					.font(.system(size: max(1, d * iconScale), weight: .semibold))
					.symbolRenderingMode(.monochrome)
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
		// Use environment foreground style (default .primary)
		RoundButtonView { }

		// Override from outside
		RoundButtonView(systemImageName: "pencil", action: {})
			.foregroundStyle(.white)

		// You can also use gradients or palettes:
		RoundButtonView(systemImageName: "star.fill", action: {})
			.symbolRenderingMode(.palette)
			.foregroundStyle(.white, .yellow)
	}
	.padding()
}
