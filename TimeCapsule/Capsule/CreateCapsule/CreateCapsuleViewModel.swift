import SwiftUI
import Observation

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

    func seal() {
		print("sealing")
		Task {
			do {
				let saved = try await saveSelectedFiles()
				print(saved)
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
