import Foundation
import SwiftData

@Model
class SavedMediaModel {

	var id: UUID
	var path: URL
	var mediaType: MediaTypes

	init(id: UUID, path: URL, mediaType: MediaTypes) {
		self.id = id
		self.path = path
		self.mediaType = mediaType
	}
}
