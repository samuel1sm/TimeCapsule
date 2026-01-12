import SwiftUI
import Combine

struct CameraView: View {

	@Environment(\.dismiss) private var dismiss
	@StateObject private var model = CameraService()
	@State private var showPreview = false
	@State private var isPhotoSelected = true

	// Recording timer state
	@State private var recordingStartDate: Date?
	@State private var elapsedSeconds: Int = 0
	@State private var timerActive: Bool = false
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let saveImageAction: (MediaModel) -> Void

	private var capturedMediaIsEmpty: Bool {
		model.capturedPhotoURL == nil && model.capturedVideoURL == nil
	}

	var body: some View {
		ZStack {
#if targetEnvironment(simulator)
			Color.white.ignoresSafeArea()
#else
			CameraRepresentable(session: model.session) { layer in
				model.attachPreviewLayer(layer)
			}
#endif

			VStack {
				// Top bar that extends into the top safe area, with centered timer
				HStack(alignment: .center) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "x.circle.fill")
							.resizable()
							.frame(width: 24, height: 24)
							.scaledToFit()
							.foregroundStyle(.white)
							.padding(.all, 24)
					}
					.padding(.top, 16)
					Spacer()
				}
				.overlay(alignment: .center) {
					if !isPhotoSelected {
						Text(formattedTime(elapsedSeconds))
							.font(.system(.headline, design: .monospaced))
							.padding(.horizontal, 12)
							.padding(.vertical, 6)
							.background(Color.black.opacity(0.4))
							.foregroundStyle(.white)
							.clipShape(Capsule())
					}
				}
				.frame(maxWidth: .infinity)
				.padding(.top, 12)
				.background(Color.black.opacity(0.4))
				.ignoresSafeArea(edges: .top)

				Spacer()

				VStack {
					ImageToggle(
						isOn: $isPhotoSelected,
						leftLabel: "Video",
						rightLabel: "Photo",
						onThumbImage: Image(systemName: "camera"),
						offThumbImage: Image(systemName: "recordingtape"),
						onColor: .blue,
						offColor: .red
					)
					.padding(.vertical, 16)

					HStack(spacing: 20) {
						Button {
							if isPhotoSelected {
								model.takePhoto()
							} else {
								model.toggleRecording()
							}
						} label: {
							ZStack(alignment: .center) {
								Circle().frame(width: 80).foregroundStyle(model.isRecording ? Color.red : Color.white)
								Circle().frame(width: 70).foregroundStyle(Color.black.opacity(0.4))
								Circle().frame(width: 60).foregroundStyle(model.isRecording ? Color.red : Color.white)
							}
						}
					}
					.frame(maxWidth: .infinity)
					.overlay(alignment: .trailing) {
						Button {
							model.switchCamera()
						} label: {
							Image(systemName: "arrow.triangle.2.circlepath.camera")
								.font(.system(size: 18, weight: .semibold))
								.padding(12)
								.background(Color.black.opacity(0.6))
								.foregroundColor(.white)
								.clipShape(Circle())
						}
					}
				}
				.padding(.horizontal, 16)
				.padding(.bottom, 40)
				.background(Color.black.opacity(0.4))
			}

			// Loading overlay while processing merged/exported video
			if model.isProcessing {
				Color.black.opacity(0.5)
					.ignoresSafeArea()
				MediaLoadingView(progress: model.processingProgress)
			}
		}
		.ignoresSafeArea()
		.onAppear { model.start() }
		.onDisappear { model.stop() }
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
		.onReceive(timer) { _ in
			guard !showPreview else { return }
			guard timerActive, let start = recordingStartDate else { return }
			elapsedSeconds = max(0, Int(Date().timeIntervalSince(start)))
		}
		.onChange(of: capturedMediaIsEmpty) {
			if !capturedMediaIsEmpty {
				model.stop()
				showPreview = true
			}
		}
		.fullScreenCover(
			isPresented: $showPreview,
			onDismiss: { model.discardCapture() }
		) {
			CapturePreviewView(
				capturedPhotoURL: model.capturedPhotoURL,
				capturedVideoURL: model.capturedVideoURL,
				saveMedia: { [model, saveImageAction] in
					model.saveCaptureToPhotos()
					// TODO: adjust MediaModel init as needed for your real data.
					saveImageAction(.init(type: .video, url: []))
				},
				cancelSave: {
					model.start()
				}
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
	CameraView(saveImageAction: {_ in })
}
