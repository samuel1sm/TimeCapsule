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
        // TODO: persist / call API
    }

    func reset() {
        title = ""
        message = ""
        unlockDate = nil
        isPrivate = true
        selectedMedia.removeAll()
    }
}
