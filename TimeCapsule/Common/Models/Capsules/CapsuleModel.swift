import Foundation
import SwiftData

@Model
class CapsuleModel {

	var capsuleID: UUID
	var title: String
	var details: String
	var date: Date
	var persistedFIles: [SavedMediaModel]
	var creationDate: Date

	init(
		capsuleID: UUID,
		title: String,
		details: String,
		date: Date,
		persistedFIles: [SavedMediaModel],
		creationDate: Date
	) {
		self.capsuleID = capsuleID
		self.title = title
		self.details = details
		self.date = date
		self.persistedFIles = persistedFIles
		self.creationDate = creationDate
	}
}
