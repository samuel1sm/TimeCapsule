import Foundation

struct EntryModel: Identifiable {

	let id: UUID
	let entryType: LogEntryOptions
	let noteModel: NoteModel?
	let mediaModel: MediaModel?

	init(
		id: UUID = UUID(),
		entryType: LogEntryOptions,
		noteModel: NoteModel? = nil,
		mediaModel: MediaModel? = nil
	) {
		self.id = id
		self.entryType = entryType
		self.noteModel = noteModel
		self.mediaModel = mediaModel
	}
}

