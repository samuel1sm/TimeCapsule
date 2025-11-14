import Foundation
import SwiftData

@Model
class CapsuleModel {

	var capsuleID: UUID
	var title: String
	var details: String
	var date: Date
	var persistedFIles: [SavedMediaModel]

	init(capsuleID: UUID, title: String, description: String, date: Date, persistedFIles: [SavedMediaModel]) {
		self.capsuleID = capsuleID
		self.title = title
		self.details = description
		self.date = date
		self.persistedFIles = persistedFIles
	}
}
