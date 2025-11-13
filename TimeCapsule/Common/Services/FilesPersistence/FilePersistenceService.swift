import Foundation

protocol FilePersistenceServiceProtocol {

	func saveFiles(at id: UUID, files: [PersistenceFilesModel]) async throws -> [PersistedFilesModel]
	func getFIles(at id: UUID) -> [PersistedFilesModel]
}


class FilePersistenceService: FilePersistenceServiceProtocol {

	func saveFiles(at id: UUID, files: [PersistenceFilesModel]) async throws -> [PersistedFilesModel] {
		let (destination, manager) = FileManager.getPathAndManager(with: id)
		var result = [PersistedFilesModel]()
		try await withThrowingTaskGroup(of: PersistedFilesModel.self) { group in
				for file in files {
					group.addTask {
						let newID = UUID()
						let exten = file.temporaryPath.pathExtension
						let fileName = newID.uuidString + "." + exten
						let newPath = destination.appendingPathComponent(fileName)

						if manager.fileExists(atPath: newPath.path) {
							try manager.removeItem(at: newPath)
						}

						try manager.copyItem(at: file.temporaryPath, to: newPath)
						return .init(id: newID, path: newPath, type: file.mediaType)
					}
				}

			for try await newItem in group {
				result.append(newItem)
			}
		}
		return result
	}

	func getFIles(at id: UUID) -> [PersistedFilesModel] {
		return []
	}
}
