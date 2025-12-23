import SwiftUI
import AVFoundation
import AVKit

struct CapturePreviewView: View {
	@ObservedObject var model: CameraService
	@Binding var isPresented: Bool

	var body: some View {
		VStack(spacing: 16) {
			Group {
				if let url = model.capturedPhotoURL,
				   let uiImage = UIImage(contentsOfFile: url.path) {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFit()
				} else if let url = model.capturedVideoURL {
					VideoPlayer(player: AVPlayer(url: url))
						.scaledToFit()
				} else {
					Text("Nothing captured.")
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)

			HStack(spacing: 16) {
				Button("Retake") {
					model.discardCapture()
					isPresented = false
				}
				.buttonStyle(.bordered)

				Button("Save") {
					model.saveCaptureToPhotos()
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
