extension PersistedFilesModel {

	var savedMediaModel: SavedMediaModel {
		.init(id: id, path: path, mediaType: mediaType)
	}
}
