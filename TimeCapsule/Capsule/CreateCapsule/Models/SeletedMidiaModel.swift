import Foundation

enum MediaTypes {

	case image
	case video
}

struct SelectedMediaModel {

	let type: MediaTypes
	let url: URL
}
