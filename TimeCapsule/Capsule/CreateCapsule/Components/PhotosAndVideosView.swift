import SwiftUI
import PhotosUI

struct PhotosAndVideosView: View {
	@Binding var selectedItems: [PhotosPickerItem]
	@State private var selectedImages: [Image] = []
	@State private var width: CGFloat = 100

	var body: some View {
		let spacing: CGFloat = 12
		let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
		let itemWidth = (width - spacing * 3) / 4
		let rows = Int(ceil(Double(selectedImages.count) / 4))
		let visibleRows = min(rows, 4)
		let gridHeight = itemWidth * CGFloat(visibleRows)
		+ spacing * CGFloat(max(visibleRows - 1, 0))

		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text("Photos & Videos")
					.font(.headline)
				Spacer()
				if !selectedItems.isEmpty {
					Button("Clear") {
						selectedItems.removeAll()
						selectedImages.removeAll()
					}.font(.subheadline)
				}
			}

			VStack(spacing: 16) {
				if !selectedImages.isEmpty {
						ScrollView {
							LazyVGrid(columns: columns, spacing: spacing) {
								ForEach(selectedImages.indices, id: \.self) { i in
									selectedImages[i]
										.resizable()
										.scaledToFill()
										.frame(width: itemWidth, height: itemWidth)
										.clipped()
										.cornerRadius(8)
								}
							}
						}
						.scrollDisabled(selectedImages.count <= 16)
						.frame(height: gridHeight)
				}

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
			.onChange(of: selectedItems) {
				selectedImages.removeAll()
				Task {
					for item in selectedItems {
						if let loadedImage = try? await item.loadTransferable(type: Image.self) {
							selectedImages.append(loadedImage)
						}
					}
				}
			}
		}
		.overlay {
			GeometryReader { proxy in
				Color.clear.task(id: proxy.size) {
					width = proxy.size.width
				}
			}
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
