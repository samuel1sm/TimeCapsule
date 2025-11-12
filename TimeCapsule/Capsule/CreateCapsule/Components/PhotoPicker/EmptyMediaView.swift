import SwiftUI

struct EmptyMediaView: View {
	var onTap: () -> Void

	var body: some View {
		VStack(spacing: 12) {
			Image(systemName: "arrow.up.circle")
				.font(.system(size: 36))
				.foregroundColor(Color.purple)
			Text("Add photos or videos")
				.font(.subheadline)
				.foregroundColor(.primary)
			Text("Tap to upload media")
				.font(.footnote)
				.foregroundColor(.gray)
			HStack(spacing: 16) {
				Image(systemName: "photo.on.rectangle")
				Image(systemName: "video")
			}
			.foregroundColor(.gray)
		}
		.frame(maxWidth: .infinity)
		.contentShape(Rectangle())
		.onTapGesture(perform: onTap)
	}
}

#Preview {
	EmptyMediaView(onTap: {})
}
