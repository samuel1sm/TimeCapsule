import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVKit

private struct PickedVideo: Transferable {
	let url: URL

	static var transferRepresentation: some TransferRepresentation {
		FileRepresentation(contentType: .movie) { movie in
			SentTransferredFile(movie.url)
		} importing: { received in
 			let (folder, fileManager) = await FileManager.getPathAndManager()

			// 3) Build unique file name
			let ext = received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension
			let fileName = UUID().uuidString + "." + ext
			let destination = folder.appendingPathComponent(fileName)

			// 4) Replace if somehow exists
			if fileManager.fileExists(atPath: destination.path) {
				try fileManager.removeItem(at: destination)
			}

			// 5) Copy from the security-scoped temp into our persistent dir
			try fileManager.copyItem(at: received.file, to: destination)
			return .init(url: destination)
		}
	}
}

struct PhotosAndVideosView: View {
	@Binding var selectedMediaModel: [SelectedMediaModel]
	@State private var selectedItems: [PhotosPickerItem] = []
	@State private var width: CGFloat = 100
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
						selectedMediaModel.removeAll()
						selectedItems.removeAll()
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
		let rows = Int(ceil(Double(selectedMediaModel.count) / 4))
		let visibleRows = min(rows, 4)
		let gridHeight = itemWidth * CGFloat(visibleRows)
		+ spacing * CGFloat(max(visibleRows - 1, 0))

		if !selectedMediaModel.isEmpty {
			ScrollView {
				LazyVGrid(columns: columns, spacing: spacing) {
					ForEach(selectedMediaModel.indices, id: \.self) { i in
						ZStack(alignment: .topTrailing) {
							let model = selectedMediaModel[i]
							LocalVideoPlayerView(model: model)
								.frame(width: itemWidth, height: itemWidth)
								.clipped()
								.cornerRadius(8)
							Button {
								selectedMediaModel.remove(at: i)
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
			.scrollDisabled(selectedMediaModel.count <= 16)
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
			if selectedMediaModel.isEmpty {
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
		.onChange(of: isShowingPhotoPicker) { _, isOpen in
			guard !isOpen else { return }
			handleSelectedFiles()
		}
		.onChange(of: selectedMediaModel) { _, newValue in
			guard newValue.isEmpty else { return }
			selectedItems.removeAll()
		}
	}

	private func handleSelectedFiles() {
		let (timeCapsuleFolder, _) = FileManager.getPathAndManager()
		Task {
			imagesAreLoading = true
			var newSelected = [SelectedMediaModel]()
			for item in selectedItems {
				// Try importing as a movie first; if it fails, fall back to image
				if let movie = try? await item.loadTransferable(type: PickedVideo.self) {
					newSelected.append(.init(type: .video, url: movie.url))
					continue
				}

				if let data = try? await item.loadTransferable(type: Data.self),
				   let _ = UIImage(data: data) {

					let fileName = UUID().uuidString + ".png"
					let destination = timeCapsuleFolder.appendingPathComponent(fileName)
					
					do {
						try data.write(to: destination, options: .atomic)
					} catch {
						print("Failed to save image:", error)
					}
					newSelected.append(.init(type: .image, url: destination))
				}
				
				await MainActor.run {
					selectedMediaModel = newSelected
					imagesAreLoading = false
				}
			}
		}
	}
}

private struct PhotosAndVideosPreviewHost: View {
	@State private var items: [SelectedMediaModel] = []

	var body: some View {
		PhotosAndVideosView(selectedMediaModel: $items)
			.padding()
	}
}

#Preview("Interactive Binding") {
	PhotosAndVideosPreviewHost()
}
