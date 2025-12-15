import Foundation

struct EntryModel: Identifiable {

	let id: UUID
	let entryType: LogEntryOptions
	let noteModel: NoteModel?

	init(
		id: UUID = UUID(),
		entryType: LogEntryOptions,
		noteModel: NoteModel? = nil
	) {
		self.id = id
		self.entryType = entryType
		self.noteModel = noteModel
	}
}

struct NoteModel {

	let note: String
	let mood: MoodOptions?
}
