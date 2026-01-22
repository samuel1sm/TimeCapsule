import SwiftUI

struct LocalMediaView: View {
	let media: MediaData

	var body: some View {
		switch media.mediaType {
		case .image:
			LocalFileImage(url: media.url)
		case .video:
			LocalVideoPlayerView(model: .init(type: .video, url: media.url, identifier: 0))
		}
	}
}

// MARK: - Previews

#Preview("Image") {
	LocalMediaView(media: MediaData(
		mediaType: .image,
		url: URL(string: "https://live.staticflickr.com/9/8865/17270333843_bb7eae34ef_z.jpg")!
	))
	.frame(width: 120, height: 120)
	.clipped()
	.cornerRadius(12)
}

#Preview("Video") {
	LocalMediaView(media: MediaData(
		mediaType: .video,
		url: URL(string: "https://file-examples.com/storage/fe6e2b4c6172e8a69ee02d6/2017/04/file_example_MP4_480_1_5MG.mp4")!
	))
	.frame(width: 120, height: 120)
	.cornerRadius(12)
}
