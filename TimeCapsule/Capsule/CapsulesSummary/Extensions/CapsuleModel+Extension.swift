extension CapsuleModel {

	var capsuleItem: CapsuleItem {
		.init(
			id: capsuleID,
			title: title,
			openDate: date,
			firstImageURl: persistedFIles.first?.path
		)
	}
}
