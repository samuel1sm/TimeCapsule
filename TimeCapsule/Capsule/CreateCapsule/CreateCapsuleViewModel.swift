import SwiftUI
import Observation
import SwiftData

@Observable
final class CreateCapsuleViewModel {

	// Form fields
    var title: String = ""
    var message: String = ""
    var unlockDate: Date? = nil
    var isPrivate: Bool = true
	var selectedMedia: [SelectedMediaModel] = []

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

	func seal(with context: ModelContext) {
		guard let unlockDate else {
			print("error: date invalid")
			return
		}
		Task {
			do {
				let savedFiles = try await saveSelectedFiles()
				context.insert(
					CapsuleModel(
						capsuleID: capsuleID,
						title: title,
						description: message,
						date: unlockDate,
						persistedFIles: savedFiles.map(\.savedMediaModel)
					)
				)
			} catch {
				print("error: \(error)")
			}
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
