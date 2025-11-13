class ServicesSingletons {

	private static var filePersistenceService: FilePersistenceServiceProtocol?

	static func getFilePersistenceService() -> FilePersistenceServiceProtocol {
		if let filePersistenceService {
			return filePersistenceService
		} else {
			let newService = FilePersistenceService()
			filePersistenceService = newService
			return newService
		}
	}
}
