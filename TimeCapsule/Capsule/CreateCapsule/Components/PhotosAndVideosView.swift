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
	@State private var oldSelectedItems: [PhotosPickerItem] = []
	@State private var width: CGFloat = 100
	@State private var imagesAreLoading = false
	@State private var isShowingPhotoPicker = false
	@State private var importedItemsCache: [Int: SelectedMediaModel] = [:]

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
				if selectedMediaModel.isEmpty && !imagesAreLoading {
					EmptyMediaView { isShowingPhotoPicker = true }
				} else {
					ImageViewBuilder()
				}
			}.frame(maxWidth: .infinity)
				.padding()
				.background{
					RoundedRectangle(cornerRadius: 12)
						.strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
				}
		}.photosPicker(
			isPresented: $isShowingPhotoPicker,
			selection: $selectedItems,
			matching: .any(of: [.images, .videos]),
			preferredItemEncoding: .current
		).onChange(of: isShowingPhotoPicker) { _, isOpen in
			if isOpen {
				oldSelectedItems = selectedItems
				return
			}
			guard oldSelectedItems != selectedItems else {
				oldSelectedItems.removeAll()
				return
			}
			handleSelectedFiles()
		}
		.onChange(of: selectedMediaModel) { _, newValue in
			guard newValue.isEmpty && !imagesAreLoading else { return }
			selectedItems.removeAll()
		}
	}

	@ViewBuilder
	private func ImageViewBuilder() -> some View {
		let spacing: CGFloat = 10
		let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
		let itemWidth = (width - spacing * 3) / 4
		let rows = Int(ceil(Double(selectedMediaModel.count) / 4))
		let visibleRows = min(rows, 4)
		let gridHeight = itemWidth * CGFloat(visibleRows)
		+ spacing * CGFloat(max(visibleRows - 1, 0))

		VStack {
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
									removeItems(at: i)
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

				if imagesAreLoading {
					ProgressView()
						.progressViewStyle(.circular)
						.padding(.top, 16)
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
	}

	private func removeItems(at position: Int) {
		let model =  selectedMediaModel.remove(at: position)
		selectedItems.removeAll { $0.hashValue == model.identifier }
		importedItemsCache.removeValue(forKey: model.identifier)
	}

	private func handleSelectedFiles() {
		let (timeCapsuleFolder, _) = FileManager.getPathAndManager()

		let preCachedItems = importedItemsCache
		imagesAreLoading = true
		selectedMediaModel = []
		Task(priority: .userInitiated) {
			await withTaskGroup(of: SelectedMediaModel?.self) { group in
				for item in selectedItems {
					group.addTask {
						if let cached = preCachedItems[item.hashValue] {
							return cached
						}

						if let movie = try? await item.loadTransferable(type: PickedVideo.self) {
							let model = SelectedMediaModel(
								type: .video,
								url: movie.url,
								identifier: item.hashValue
							)
							return model
						}

						if let data = try? await item.loadTransferable(type: Data.self) {
							let fileName = UUID().uuidString + ".png"
							let destination = timeCapsuleFolder.appendingPathComponent(fileName)

							do {
								try data.write(to: destination, options: [.atomic])
								let model = SelectedMediaModel(
									type: .image,
									url: destination,
									identifier: item.hashValue
								)
								return model
							} catch {
								print("Failed to save image:", error)
							}
						}
						return nil
					}
				}

				for await result in group {
					if let model = result {
						await MainActor.run {
							importedItemsCache[model.identifier] = model
							selectedMediaModel.append(model)
						}
					}
				}

				await MainActor.run {
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
