import SwiftUI
import AVFoundation
import AVKit

struct CapturePreviewView: View {
	@Binding var isPresented: Bool
	var capturedPhotoURL: URL?
	var capturedVideoURL: URL?
	var saveMedia: () -> ()
	var cancelSave: () -> ()

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
						.scaledToFit()
				} else {
					Text("Nothing captured.")
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)

			HStack(spacing: 16) {
				Button("Retake") {
					cancelSave()
					isPresented = false
				}
				.buttonStyle(.bordered)

				Button("Save") {
					saveMedia()
					isPresented = false
				}
				.buttonStyle(.borderedProminent)
			}
			.padding(.bottom, 24)
		}
		.padding()
		.background(.black)
		.foregroundStyle(.white)
	}
}
