import SwiftUI
import Combine

struct CameraView: View {

	@StateObject private var model = CameraService()
	@State private var showPreview = false

	// Recording timer state
	@State private var recordingStartDate: Date?
	@State private var elapsedSeconds: Int = 0
	@State private var timerActive: Bool = false
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	var body: some View {
		ZStack {
			#if targetEnvironment(simulator)
			Color.white
				.ignoresSafeArea()
			#else
			CameraRepresentable(session: model.session) { layer in
				model.attachPreviewLayer(layer)
			}
			.ignoresSafeArea()
			#endif

			// Top-center timer overlay (only while recording)
			VStack {
				HStack {
					Spacer()
					if model.isRecording {
						Text(formattedTime(elapsedSeconds))
							.font(.system(.headline, design: .monospaced))
							.padding(.horizontal, 12)
							.padding(.vertical, 6)
							.background(.black.opacity(0.6))
							.foregroundStyle(.white)
							.clipShape(Capsule())
					}
					Spacer()
				}
				.padding(.top, 12)

				Spacer()
			}

			VStack {
				Spacer()

				ZStack {
					HStack {
						Spacer()
						
						HStack(spacing: 20) {
							Button {
								model.takePhoto()
								showPreview = true
							} label: {
								Text("Photo")
									.frame(width: 60)
									.padding(.horizontal, 24).padding(.vertical, 16)
									.background(.black.opacity(0.6))
									.foregroundStyle(.white)
									.clipShape(Capsule())
							}
							
							Button {
								model.toggleRecording()
							} label: {
								Text(model.isRecording ? "Stop" : "Record")
									.frame(width: 60)
									.padding(.horizontal, 24).padding(.vertical, 16)
									.background(model.isRecording ? .red.opacity(0.7) : .black.opacity(0.6))
									.foregroundStyle(.white)
									.clipShape(Capsule())
							}
						}
						
						Spacer()
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
		// Drive timer start/stop based on recording state
		.onChange(of: model.isRecording) { _, newValue in
			if newValue {
				recordingStartDate = Date()
				elapsedSeconds = 0
				timerActive = true
			} else {
				timerActive = false
				recordingStartDate = nil
				elapsedSeconds = 0
			}
		}
		// Tick every second while active
		.onReceive(timer) { _ in
			guard timerActive, let start = recordingStartDate else { return }
			elapsedSeconds = max(0, Int(Date().timeIntervalSince(start)))
		}
		.onChange(of: model.capturedPhotoURL) { _, newValue in
			if newValue != nil { showPreview = true }
		}
		.onChange(of: model.capturedVideoURL) { _, newValue in
			if newValue != nil { showPreview = true }
		}
		.fullScreenCover(isPresented: $showPreview) {
			CapturePreviewView(
				model: model,
				isPresented: $showPreview,
				saveMedia: { model.saveCaptureToPhotos() },
				cancelSave: model.discardCapture
			)
		}
		.alert("Camera Error", isPresented: .constant(model.errorMessage != nil)) {
			Button("OK") { model.errorMessage = nil }
		} message: {
			Text(model.errorMessage ?? "")
		}
	}

	private func formattedTime(_ seconds: Int) -> String {
		let m = seconds / 60
		let s = seconds % 60
		return String(format: "%02d:%02d", m, s)
	}
}


#Preview("CameraView") {
	CameraView()
}
