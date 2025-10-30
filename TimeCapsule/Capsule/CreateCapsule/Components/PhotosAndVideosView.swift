import SwiftUI

struct PhotosAndVideosView: View {
	@Binding var showMediaPicker: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Photos & Videos")
				.font(.headline)
			Button {
				showMediaPicker.toggle()
			} label: {
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
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
				)
			}
		}
	}
}

#Preview {
	PhotosAndVideosView(showMediaPicker: .constant(true))
}
