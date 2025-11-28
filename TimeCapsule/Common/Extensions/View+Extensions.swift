import SwiftUI

extension View {

	func roundedBackground(
		cornerRadius: CGFloat = 20,
		backgroundColor: Color = Color(.systemBackground),
		borderColor: Color = Color.black.opacity(0.06)
	) -> some View {
		self
			.background(
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.fill(backgroundColor)
			)
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.stroke(borderColor)
			)
	}
}
