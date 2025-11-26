import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class CapsulesSummaryViewModel {

    var isDeleteMode = false
    var showDeleteDialog = false
    var capsuleToDelete: CapsuleModel?

    func confirmDeletion(of capsule: CapsuleModel) {
        capsuleToDelete = capsule
        showDeleteDialog = true
    }

    func cancelDeletion() {
        showDeleteDialog = false
        capsuleToDelete = nil
    }

    func performDelete(using context: ModelContext, from capsules: [CapsuleModel]) {
        guard let id = capsuleToDelete?.capsuleID else { return }
        guard let model = capsules.first(where: { $0.capsuleID == id }) else {
            cancelDeletion()
            return
        }
        context.delete(model)
        do {
            try context.save()
        } catch {
            print("Failed to delete capsule:", error)
        }
        isDeleteMode = false
        cancelDeletion()
    }
}
