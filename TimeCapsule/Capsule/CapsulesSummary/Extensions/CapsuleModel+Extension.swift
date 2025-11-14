extension CapsuleModel {

	func toCapsuleItem() -> CapsuleItem {
		.init(title: title, openDate: date, firstImageURl: persistedFIles.first?.path)
	}
}
