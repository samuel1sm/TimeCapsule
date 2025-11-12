import Foundation

extension FileManager {

	static func getPathAndManager(with id: UUID) -> (URL, FileManager){
		let fileManager = FileManager.default
		let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let folder = documentsURL.appendingPathComponent("TimeCapsule/\(id)", isDirectory: true)

		if !fileManager.fileExists(atPath: folder.path) {
			try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
		}

		return (folder, fileManager)
	}

	static func getTemporaryPathAndManager() -> (URL, FileManager) {
		let fileManager = FileManager.default
		let tempURL = fileManager.temporaryDirectory
		let folder = tempURL.appendingPathComponent("TimeCapsule", isDirectory: true)

		if !fileManager.fileExists(atPath: folder.path) {
			try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
		}

		return (folder, fileManager)
	}
}
