import Foundation

extension PersistedFilesModel {

	var savedMediaModel: SavedMediaModel {
		.init(
			id: id,
			fileName: path.lastPathComponent,
			mediaType: mediaType
		)
	}
}
