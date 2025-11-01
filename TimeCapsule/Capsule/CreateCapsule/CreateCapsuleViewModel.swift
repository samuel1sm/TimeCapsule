import SwiftUI
import Observation

@Observable
final class CreateCapsuleViewModel {
    // Form fields
    var title: String = ""
    var message: String = ""
    var unlockDate: Date = .now
    var isPrivate: Bool = true

    // Media
    var showMediaPicker: Bool = false
    var selectedMedia: [UIImage] = []

    // Derived state
    var canSeal: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Actions
    func toggleMediaPicker(_ flag: Bool? = nil) {
        if let flag { showMediaPicker = flag } else { showMediaPicker.toggle() }
    }

    func addMedia(_ images: [UIImage]) {
        selectedMedia.append(contentsOf: images)
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
        unlockDate = .now
        isPrivate = true
        selectedMedia.removeAll()
        showMediaPicker = false
    }
}
