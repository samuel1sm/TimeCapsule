import Foundation
import SwiftUI
import AVFoundation

struct TemporaryPickedVideo: Transferable {
	let url: URL

	static var transferRepresentation: some TransferRepresentation {
		FileRepresentation(contentType: .movie) { movie in
			SentTransferredFile(movie.url)
		} importing: { received in
			let (folder, fileManager) = await FileManager.getTemporaryPathAndManager()

			// 3) Build unique file name
			let ext = received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension
			let fileName = UUID().uuidString + "." + ext
			let destination = folder.appendingPathComponent(fileName)

			// 4) Replace if somehow exists
			if fileManager.fileExists(atPath: destination.path) {
				try fileManager.removeItem(at: destination)
			}

			// 5) Copy from the security-scoped temp into our persistent dir
			try fileManager.copyItem(at: received.file, to: destination)
			return .init(url: destination)
		}
	}
}
