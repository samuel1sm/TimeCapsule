import Foundation

extension FileManager {

	static func getPathAndManager() -> (URL, FileManager){
		let capsuleFolder = CreateCapsuleViewModel.capsuleID ?? UUID()
		let fileManager = FileManager.default
		let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let folder = documentsURL.appendingPathComponent("TimeCapsule\(capsuleFolder)", isDirectory: true)

		if !fileManager.fileExists(atPath: folder.path) {
			try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
		}

		return (folder, fileManager)
	}
}
