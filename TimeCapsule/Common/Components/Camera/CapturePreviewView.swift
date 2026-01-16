import SwiftUI
import AVFoundation
import AVKit

struct CapturePreviewView: View {
	@Environment(\.dismiss) private var dismiss
	var capturedPhotoURL: URL?
	var capturedVideoURL: URL?
	var saveMedia: () -> ()
	var cancelSave: () -> ()

	// Holds the computed width/height aspect ratio of the video (e.g. 9/16 for portrait)
	@State private var videoAspectRatio: CGFloat?

	var body: some View {
		VStack(spacing: 16) {
			Group {
				if let url = capturedPhotoURL,
				   let uiImage = UIImage(contentsOfFile: url.path) {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFit()
				} else if let url = capturedVideoURL {
					VideoPlayer(player: AVPlayer(url: url))
						.aspectRatio(videoAspectRatio ?? (9.0 / 16.0), contentMode: .fit)
						.task(id: url) {
							videoAspectRatio = await loadAspectRatio(for: url) ?? (9.0 / 16.0)
						}
				} else {
					Text("Nothing captured.")
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)

			HStack(spacing: 16) {
				Button("Retake") {
					cancelSave()
					dismiss()
				}
				.buttonStyle(.bordered)

				Button("Save") {
					saveMedia()
					dismiss()
				}
				.buttonStyle(.borderedProminent)
			}
			.padding(.bottom, 24)
		}
		.padding(.vertical)
		.background(.black)
		.foregroundStyle(.white)
	}

	private func loadAspectRatio(for url: URL) async -> CGFloat? {
		let asset = AVURLAsset(url: url)
		do {
			guard let track = try await asset.loadTracks(withMediaType: .video).first else { return nil }
			let naturalSize = try await track.load(.naturalSize)
			let transform = try await track.load(.preferredTransform)

			// Apply the transform to get the display size
			let transformedRect = CGRect(origin: .zero, size: naturalSize).applying(transform)
			let displaySize = CGSize(width: abs(transformedRect.width), height: abs(transformedRect.height))

			guard displaySize.width > 0, displaySize.height > 0 else { return nil }
			return displaySize.width / displaySize.height
		} catch {
			return nil
		}
	}
}
