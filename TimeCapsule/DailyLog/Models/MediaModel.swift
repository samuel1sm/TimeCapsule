import Foundation

struct MediaModel {

	let items: [MediaData]
}

struct MediaData {

	let mediaType: MediaTypes
	let url: URL
}

extension CameraViewResultModel {

	func toMediaData() -> MediaData {
		.init(mediaType: mediaType, url: url)
	}
}
