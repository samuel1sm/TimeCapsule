import SwiftUI
import Observation
import SwiftData

@MainActor
@Observable
final class CreateCapsuleViewModel {

	// Form fields
    var title: String = ""
    var message: String = ""
    var unlockDate: Date? = nil
    var isPrivate: Bool = true
	var selectedMedia: [SelectedMediaModel] = []
	var isLoading = false
	private let capsuleID = UUID()

    // Derived state
    var canSeal: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
		unlockDate != nil
    }

    func removeMedia(at offsets: IndexSet) {
        for i in offsets.reversed() { selectedMedia.remove(at: i) }
    }

	// Returns true on success so the view can dismiss itself.
	func seal(with context: ModelContext) async -> Bool {
		guard let unlockDate else {
			print("error: date invalid")
			return false
		}
		isLoading = true
		defer { isLoading = false }

		do {
			let savedFiles = try await saveSelectedFiles()

			let model = CapsuleModel(
				capsuleID: capsuleID,
				title: title,
				details: message,
				date: unlockDate,
				persistedFIles: savedFiles.map(\.savedMediaModel),
				creationDate: Date()
			)
			context.insert(model)

			try context.save()

			return true
		} catch {
			print("error: \(error)")
			return false
		}
    }

	private func saveSelectedFiles() async throws -> [PersistedFilesModel] {
		let service = ServicesSingletons.getFilePersistenceService()
		let files = selectedMedia.map(\.persistenceFilesModel)
		return try await service.saveFiles(at: capsuleID, files: files)
	}

    func reset() {
        title = ""
        message = ""
        unlockDate = nil
        isPrivate = true
        selectedMedia.removeAll()
    }
}
