import Foundation
import SwiftUI

struct LocalFileImage: View {
	let url: URL

	@State private var uiImage: UIImage?
	@State private var failed = false

	var body: some View {
		ZStack {
			if let uiImage {
				Image(uiImage: uiImage)
					.resizable()
					.scaledToFill()
			} else if failed {
				ZStack {
					Color(.systemGray6)
					Image(systemName: "photo")
						.resizable()
						.scaledToFit()
						.foregroundColor(.gray)
						.padding(24)
				}
			} else {
				ProgressView()
			}
		}
		// Re-run the load whenever the URL changes
		.task(id: url) { await loadImage() }
	}

	private func loadImage() async {
		failed = false
		uiImage = nil
		let fileURL = url
		do {
			// Read data off the main actor
			let data = try await Task.detached(priority: .userInitiated) {
				try Data(contentsOf: fileURL, options: [.mappedIfSafe])
			}.value

			guard let image = UIImage(data: data) else {
				await MainActor.run { failed = true }
				return
			}
			await MainActor.run { uiImage = image }
		} catch {
			await MainActor.run { failed = true }
		}
	}
}
