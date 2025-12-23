import SwiftUI
import AVKit

struct CameraView: View {

	@StateObject private var model = CameraService()
	@State private var showPreview = false

	var body: some View {
		ZStack {
			#if targetEnvironment(simulator)
			// Simulator: show a plain white screen
			Color.white
				.ignoresSafeArea()
			#else
			// Real device: show the camera preview
			CameraRepresentable(session: model.session) { layer in
				model.attachPreviewLayer(layer)
			}
			.ignoresSafeArea()
			#endif

			VStack {
				Spacer()

				ZStack {
					HStack {
						// Existing capture controls centered-ish
						Spacer()
						
						HStack(spacing: 20) {
							Button {
								model.takePhoto()
								showPreview = true
							} label: {
								Text("Photo")
									.padding(.horizontal, 24).padding(.vertical, 16)
									.background(.black.opacity(0.6))
									.foregroundStyle(.white)
									.clipShape(Capsule())
							}
							
							Button {
								model.toggleRecording()
							} label: {
								Text(model.isRecording ? "Stop" : "Record")
									.padding(.horizontal, 24).padding(.vertical, 16)
									.background(model.isRecording ? .red.opacity(0.7) : .black.opacity(0.6))
									.foregroundStyle(.white)
									.clipShape(Capsule())
							}
						}
						
						Spacer()
						
						// Bottom-right camera switch button
					}

					HStack {
						Spacer()
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
				}
				.padding(.horizontal, 16)
				.padding(.bottom, 40)
			}

			// Loading overlay while processing merged/exported video
			if model.isProcessing {
				Color.black.opacity(0.5)
					.ignoresSafeArea()
				MediaLoadingView(progress: model.processingProgress)
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


#Preview("CameraView") {
	CameraView()
}
