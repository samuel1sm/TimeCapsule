import Foundation
import SwiftData

@Model
class SavedMediaModel {

	var id: UUID
	var fileName: String
	var mediaType: MediaTypes

	init(id: UUID, fileName: String, mediaType: MediaTypes) {
		self.id = id
		self.fileName = fileName
		self.mediaType = mediaType
	}
}
