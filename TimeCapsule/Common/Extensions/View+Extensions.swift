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

	func readSize(_ size: Binding<CGSize>) -> some View {
		background(
			GeometryReader { proxy in
				Color.clear
					.preference(key: SizePreferenceKey.self, value: proxy.size)
			}
		)
		.onPreferenceChange(SizePreferenceKey.self) { newSize in
			if size.wrappedValue != newSize {
				size.wrappedValue = newSize
			}
		}
	}
}
