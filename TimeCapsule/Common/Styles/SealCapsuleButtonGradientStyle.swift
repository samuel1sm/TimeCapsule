import SwiftUI

extension ButtonStyle where Self == SealCapsuleGradientStyle {
	/// Enables `.buttonStyle(.sealCapsuleGradient)` sugar.
	static var sealCapsuleGradient: SealCapsuleGradientStyle { .init() }
}

struct SealCapsuleGradientStyle: ButtonStyle {
	private let enabledColors: [Color] = [
		Color(red: 0.60, green: 0.36, blue: 1.00), // purple-ish
		Color(red: 0.92, green: 0.32, blue: 0.64)  // pink-ish
	]
	private let disabledColors: [Color] = [
		Color(red: 0.88, green: 0.80, blue: 1.00), // light purple
		Color(red: 0.98, green: 0.82, blue: 0.90)  // light pink
	]

	func makeBody(configuration: Configuration) -> some View {
		CapsuleButton(configuration: configuration,
					  enabledColors: enabledColors,
					  disabledColors: disabledColors)
	}

	private struct CapsuleButton: View {
		let configuration: Configuration
		let enabledColors: [Color]
		let disabledColors: [Color]
		@Environment(\.isEnabled) private var isEnabled

		var body: some View {
			configuration.label
				.font(.headline)
				.foregroundStyle(.white)
				.background(
					Capsule()
						.fill(
							LinearGradient(
								colors: isEnabled ? enabledColors : disabledColors,
								startPoint: .leading,
								endPoint: .trailing
							)
						)
				)
				.contentShape(Capsule())
				.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
				.opacity(configuration.isPressed ? 0.95 : 1.0)
				.animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
		}
	}
}

#Preview {
	Button {

	} label : {
		VStack {
			Text("test")
		}.frame(height: 48)
			.frame(maxWidth: .infinity)
	}.buttonStyle(.sealCapsuleGradient)
}
