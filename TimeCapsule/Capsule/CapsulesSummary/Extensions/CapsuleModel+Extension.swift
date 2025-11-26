import Foundation
extension CapsuleModel {

	func toCapsuleItem() -> CapsuleItem {
		let baseFolder = FileManager.getPathAndManager(with: capsuleID).0
		let firstImageURL: URL? = {
			guard let imageModel = persistedFIles.first(where: { $0.mediaType == .image }) else {
				return nil
			}
			return baseFolder.appendingPathComponent(imageModel.fileName)
		}()

		return .init(
			id: capsuleID,
			title: title,
			openDate: openDate,
			firstImageURl: firstImageURL
		)
	}
}
