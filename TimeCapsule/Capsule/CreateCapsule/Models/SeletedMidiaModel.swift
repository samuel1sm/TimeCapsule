import Foundation

struct SelectedMediaModel: Equatable {

	let type: MediaTypes
	let url: URL
	let identifier: Int
}

extension SelectedMediaModel {

	var persistenceFilesModel: PersistenceFilesModel {
		.init(temporaryPath: url, mediaType: type)
	}
}
