import Foundation

enum MediaTypes {

	case image
	case video
}

struct SelectedMediaModel: Equatable {

	let type: MediaTypes
	let url: URL
	let identifier: Int
}
