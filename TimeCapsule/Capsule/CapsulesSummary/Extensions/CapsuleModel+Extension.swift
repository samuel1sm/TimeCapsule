extension CapsuleModel {

	func toCapsuleItem() -> CapsuleItem {
		.init(
			id: capsuleID,
			title: title,
			openDate: openDate,
			firstImageURl: persistedFIles.first(where: { $0.mediaType == .image })?.path
		)
	}
}
