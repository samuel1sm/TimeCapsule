import SwiftUI

struct FloatingButtonView: View {
	var action: () -> Void
	var systemImageName: String = "plus"

	var body: some View {
		Button(action: action) {
			Image(systemName: systemImageName)
				.font(.system(size: 28))
				.foregroundStyle(.white)
				.padding(16)
				.background(
					LinearGradient(
						colors: [Color.pink, Color.purple],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				)
				.clipShape(Circle())
				.shadow(radius: 12, y: 6)
		}
	}
}

#Preview {
	FloatingButtonView { }
		.padding()
}
