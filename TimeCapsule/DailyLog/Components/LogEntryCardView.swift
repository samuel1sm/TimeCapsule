import SwiftUI

struct LogEntryCardView: View {

	let entry: EntryModel

	var body: some View {
		HStack(alignment: .top, spacing: 12) {
			ZStack {
				Circle()
					.fill(entry.getBaseColor().opacity(0.12))
					.frame(width: 42, height: 42)

				if entry.entryType == .mood {
					Text(entry.noteModel?.mood?.emoji ?? "")
						.font(.system(size: 18, weight: .semibold))
				} else {
					Image(systemName: entry.getIcon())
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(entry.getBaseColor())
				}
			}

			VStack(alignment: .leading, spacing: 4) {
				Text(entry.getTitle())
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(.secondary)

				entryContent
			}

			Spacer()
		}
		.padding()
		.roundedBackground()
		.padding(.leading, 4)
		.background {
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.fill(entry.getBaseColor())
		}
	}

	@ViewBuilder
	private var entryContent: some View {
		switch entry.entryType {
		case .note, .mood:
			if let model = entry.noteModel {
				Text(model.note).font(.body)
			}
		case .media:
			if let model = entry.mediaModel, !model.items.isEmpty {
				let totalCount = model.items.count
				let maxVisible = 6
				let showMore = totalCount > maxVisible
				let normalCount = showMore ? 5 : totalCount
				let itemsToShow = Array(model.items.prefix(normalCount))
				let extra = totalCount - maxVisible

				let allDisplayed: [AnyView] = {
					var views: [AnyView] = []
					for media in itemsToShow {
						views.append(
							AnyView(
								LocalMediaView(media: media)
									.scaledToFill()
									.frame(width: 80, height: 80)
									.clipped()
									.cornerRadius(12)
							)
						)
					}
					if showMore {
						views.append(AnyView(MoreItemsInformationCell(extra: extra)))
					}
					return views
				}()

				let firstRow = Array(allDisplayed.prefix(3))
				let secondRow = Array(allDisplayed.dropFirst(3))

				VStack(alignment: .leading, spacing: 8) {
					HStack(spacing: 8) {
						ForEach(firstRow.indices, id: \.self) { index in
							firstRow[index]
						}
					}
					if !secondRow.isEmpty {
						HStack(spacing: 8) {
							ForEach(secondRow.indices, id: \.self) { index in
								secondRow[index]
							}
						}
					}
				}
			}
		default:
			Text("tedst")
		}
	}
}

#Preview {
	VStack(spacing: 32) {
		LogEntryCardView(entry: .init(entryType: .note, noteModel: .init(note: "test", mood: nil)))
			.frame(minHeight: 100)

		LogEntryCardView(entry: .init(entryType: .mood, noteModel: .init(note: "test", mood: .happy)))
			.frame(minHeight: 100)

		// Four images media preview
		LogEntryCardView(
			entry: .init(
				entryType: .media,
				mediaModel: MediaModel(items: [
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1506744038136-46273834b3fb")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1465101046530-73398c7f28ca")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1516117172878-fd2c41f4a759")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d")!)
				])
			)
		)
		.frame(minHeight: 180)

		// 8 images, to show overflow indicator (should show 5 and "+2" at 6th)
		LogEntryCardView(
			entry: .init(
				entryType: .media,
				mediaModel: MediaModel(items: [
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1506744038136-46273834b3fb")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1465101046530-73398c7f28ca")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1516117172878-fd2c41f4a759")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1465101046530-73398c7f28ca")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1516117172878-fd2c41f4a759")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1516117172878-fd2c41f4a759")!),
					MediaData(mediaType: .image, url: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d")!)
				])
			)
		)
		.frame(minHeight: 180)
	}
	.padding(.horizontal)
}
