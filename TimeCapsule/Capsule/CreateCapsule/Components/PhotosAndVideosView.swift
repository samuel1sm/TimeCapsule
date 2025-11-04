import SwiftUI
import PhotosUI

struct PhotosAndVideosView: View {
	@Binding var selectedItems: [PhotosPickerItem]
	@State private var selectedImages: [Image] = []
	@State private var width: CGFloat = 0
	@State private var imagesAreLoading = false
	@State private var isShowingPhotoPicker = false

	var body: some View {
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
				if imagesAreLoading {
					ProgressView()
						.progressViewStyle(.circular)
				} else {
					notLoadingViews()
				}
			}.frame(maxWidth: .infinity)
				.padding()
				.background{
					RoundedRectangle(cornerRadius: 12)
						.strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
				}
		}
	}

	@ViewBuilder
	private func notLoadingViews() -> some View {
		let spacing: CGFloat = 10
		let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
		let itemWidth = (width - spacing * 3) / 4
		let rows = Int(ceil(Double(selectedImages.count) / 4))
		let visibleRows = min(rows, 4)
		let gridHeight = itemWidth * CGFloat(visibleRows)
		+ spacing * CGFloat(max(visibleRows - 1, 0))

		if !selectedImages.isEmpty {
			ScrollView {
				LazyVGrid(columns: columns, spacing: spacing) {
					ForEach(selectedImages.indices, id: \.self) { i in
						ZStack(alignment: .topTrailing) {
							selectedImages[i]
								.resizable()
								.scaledToFill()
								.frame(width: itemWidth, height: itemWidth)
								.clipped()
								.cornerRadius(8)
							Button {
								selectedImages.remove(at: i)
								selectedItems.remove(at: i)
							} label: {
								Image(systemName: "x.circle")
									.tint(.white)
									.padding(.all, 4)
									.background(.black.opacity(0.6))
									.clipShape(.circle)
							}.padding(2)
						}
					}
				}
			}
			.scrollDisabled(selectedImages.count <= 16)
			.frame(height: gridHeight)
			.overlay {
				GeometryReader { proxy in
					Color.clear.task(id: proxy.size) {
						width = proxy.size.width
					}
				}
			}
		}

		Group {
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
				.frame(maxWidth: .infinity)
				.contentShape(Rectangle())
				.onTapGesture { isShowingPhotoPicker = true }
			} else {
				HStack(alignment: .center, spacing: 16) {
					Image(systemName: "plus")
					Text("Add more").font(.headline)
				}
				.foregroundStyle(.black)
				.frame(height: 48)
				.frame(maxWidth: .infinity)
				.padding(.horizontal, 16)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(Color(.systemGray4), lineWidth: 1)
				)
				.contentShape(Rectangle())
				.onTapGesture { isShowingPhotoPicker = true }
			}
		}
		.photosPicker(
			isPresented: $isShowingPhotoPicker,
			selection: $selectedItems,
			matching: .any(of: [.images, .videos]),
			preferredItemEncoding: .automatic
		)
		.onChange(of: isShowingPhotoPicker) { _, hasClose in
			guard !hasClose else { return }
			Task {
				imagesAreLoading = true
				var newImages = [Image]()
				for item in selectedItems {
					if let loadedImage = try? await item.loadTransferable(type: Image.self) {
						newImages.append(loadedImage) }
				}

				await MainActor.run {
					selectedImages = newImages
					imagesAreLoading = false
				}
			}
		}
		.onChange(of: selectedItems) { _, newValue in
			guard newValue.isEmpty else { return }
			selectedImages.removeAll()
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
