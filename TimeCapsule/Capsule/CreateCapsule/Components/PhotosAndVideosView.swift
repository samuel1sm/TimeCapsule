import SwiftUI
import PhotosUI

struct PhotosAndVideosView: View {
	@Binding var selectedItems: [PhotosPickerItem]

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text("Photos & Videos")
					.font(.headline)
				Spacer()
				if !selectedItems.isEmpty {
					Button("Clear") { selectedItems.removeAll() }
						.font(.subheadline)
				}
			}

			VStack {
				Text("teste")
				PhotosPicker(
					selection: $selectedItems,
					photoLibrary: .shared()
				) {
					if selectedItems.isEmpty {
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
					} else {
						HStack(alignment: .center, spacing: 16) {
							Image(systemName: "plus")
							Text("Add more").font(.headline)
						}.foregroundStyle(.black)
							.frame(height: 48)
							.frame(maxWidth: .infinity)
							.padding(.horizontal, 16)
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(Color(.systemGray4), lineWidth: 1)
							)
					}
				}
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

private struct PhotosAndVideosPreviewHost: View {
	@State private var items: [PhotosPickerItem] = []

	var body: some View {
		PhotosAndVideosView(selectedItems: $items)
			.padding()
	}
}

#Preview("Interactive Binding") {
	PhotosAndVideosPreviewHost()
}
