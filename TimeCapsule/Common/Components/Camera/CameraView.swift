import SwiftUI
import AVKit

struct CameraView: View {

	@StateObject private var model = CameraService()
	@State private var showPreview = false

	var body: some View {
		ZStack {
			CameraRepresentable(session: model.session) { layer in
				model.attachPreviewLayer(layer)
			}
			.ignoresSafeArea()

			VStack {
				Spacer()

				HStack {
					// Existing capture controls centered-ish
					Spacer()

					HStack(spacing: 20) {
						Button {
							model.takePhoto()
							showPreview = true
						} label: {
							Text("Photo")
								.padding(.horizontal, 20).padding(.vertical, 12)
								.background(.black.opacity(0.6))
								.foregroundStyle(.white)
								.clipShape(Capsule())
						}

						Button {
							model.toggleRecording()
						} label: {
							Text(model.isRecording ? "Stop" : "Record")
								.padding(.horizontal, 20).padding(.vertical, 12)
								.background(model.isRecording ? .red.opacity(0.7) : .black.opacity(0.6))
								.foregroundStyle(.white)
								.clipShape(Capsule())
						}
					}

					Spacer()

					// Bottom-right camera switch button
					Button {
						model.switchCamera()
					} label: {
						Image(systemName: "arrow.triangle.2.circlepath.camera")
							.font(.system(size: 18, weight: .semibold))
							.padding(12)
							.background(.black.opacity(0.6))
							.foregroundStyle(.white)
							.clipShape(Circle())
					}
				}
				.padding(.horizontal, 16)
				.padding(.bottom, 40)
			}
		}
		.onAppear { model.start() }
		.onDisappear { model.stop() }
		.onChange(of: model.capturedPhotoURL) { _, newValue in
			if newValue != nil { showPreview = true }
		}
		.onChange(of: model.capturedVideoURL) { _, newValue in
			if newValue != nil { showPreview = true }
		}
		.fullScreenCover(isPresented: $showPreview) {
			CapturePreviewView(model: model, isPresented: $showPreview)
		}
		.alert("Camera Error", isPresented: .constant(model.errorMessage != nil)) {
			Button("OK") { model.errorMessage = nil }
		} message: {
			Text(model.errorMessage ?? "")
		}
	}
}

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
