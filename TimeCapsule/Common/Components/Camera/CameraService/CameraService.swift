import Foundation
import AVFoundation
import Photos
import SwiftUI
import Combine

@MainActor
final class CameraService: NSObject, ObservableObject {

	// Public state
	@Published var isRecording = false
	@Published var capturedPhotoURL: URL?
	@Published var capturedVideoURL: URL?
	@Published var errorMessage: String?

	let session = AVCaptureSession()

	private let photoOutput = AVCapturePhotoOutput()
	private let movieOutput = AVCaptureMovieFileOutput()

	private var videoDevice: AVCaptureDevice?
	private var previewLayer: AVCaptureVideoPreviewLayer?
	private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
	private var previewAngleObservation: NSKeyValueObservation?
	private var captureAngleObservation: NSKeyValueObservation?

	// MARK: - Permissions + lifecycle

	func start() {
		Task { await requestPermissionsAndConfigure() }
	}

	func stop() {
		Task { @MainActor [weak self] in
			self?.session.stopRunning()
		}
	}

	func attachPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
		previewLayer = layer
		setupRotationCoordinatorIfPossible()
	}

	private func requestPermissionsAndConfigure() async {
		let cameraGranted = await AVCaptureDevice.requestAccess(for: .video)
		let micGranted = await AVCaptureDevice.requestAccess(for: .audio)

		guard cameraGranted, micGranted else {
			errorMessage = "Camera/Microphone permission denied."
			return
		}

		Task { [weak self] in
			self?.configureSession()

			await MainActor.run {
				self?.session.startRunning()
			}
		}
	}

	// MARK: - Session config

	private func configureSession() {
		session.beginConfiguration()
		session.sessionPreset = .high

		// Video input
		guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
			  let videoInput = try? AVCaptureDeviceInput(device: camera),
			  session.canAddInput(videoInput)
		else {
			finishConfigWithError("Failed to add video input.")
			return
		}
		session.addInput(videoInput)
		videoDevice = camera

		// Audio input (needed for movie recording audio)
		if let mic = AVCaptureDevice.default(for: .audio),
		   let audioInput = try? AVCaptureDeviceInput(device: mic),
		   session.canAddInput(audioInput) {
			session.addInput(audioInput)
		}

		// Photo output
		if session.canAddOutput(photoOutput) {
			session.addOutput(photoOutput)
		}

		// Movie output
		if session.canAddOutput(movieOutput) {
			session.addOutput(movieOutput)
		}

		session.commitConfiguration()

		// Rotation coordinator after config (needs device + preview layer if available)
		DispatchQueue.main.async { [weak self] in
			self?.setupRotationCoordinatorIfPossible()
		}
	}

	private func finishConfigWithError(_ msg: String) {
		session.commitConfiguration()
		DispatchQueue.main.async { self.errorMessage = msg }
	}

	private func setupRotationCoordinatorIfPossible() {
		guard let device = videoDevice else { return }

		// Access previewLayer on the main actor when creating the coordinator
		let currentPreviewLayer = previewLayer
		let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: currentPreviewLayer)
		rotationCoordinator = coordinator

		// Keep preview level relative to gravity
		previewAngleObservation = coordinator.observe(
			\.videoRotationAngleForHorizonLevelPreview,
			 options: [.initial, .new]
		) { [weak self] _, change in
			guard let angle = change.newValue else { return }
			Task { @MainActor [weak self] in
				guard let connection = self?.previewLayer?.connection,  connection.isVideoRotationAngleSupported(angle) else { return }
				connection.videoRotationAngle = angle
			}
		}

		captureAngleObservation = coordinator.observe(
			\.videoRotationAngleForHorizonLevelCapture,
			 options: [.initial, .new]
		) { [weak self] _, change in
			guard let angle = change.newValue else { return }
			Task { @MainActor [weak self] in
				self?.applyCaptureRotationAngle(angle)
			}
		}
	}

	private func applyCaptureRotationAngle(_ angle: CGFloat) {
		if let c = photoOutput.connection(with: .video), c.isVideoRotationAngleSupported(angle) {
			c.videoRotationAngle = angle
		}
		if let c = movieOutput.connection(with: .video), c.isVideoRotationAngleSupported(angle) {
			c.videoRotationAngle = angle
		}
	}

	// MARK: - Actions

	func takePhoto() {
		let settings = AVCapturePhotoSettings()
		photoOutput.capturePhoto(with: settings, delegate: self)
	}

	func toggleRecording() {
		if isRecording {
			movieOutput.stopRecording()
			return
		}
		let url = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("mov")

		movieOutput.startRecording(to: url, recordingDelegate: self)
		isRecording = true
	}

	func discardCapture() {
		capturedPhotoURL = nil
		capturedVideoURL = nil
	}

	func saveCaptureToPhotos() {
		if let photoURL = capturedPhotoURL {
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: photoURL)
			}) { [weak self] success, error in
				DispatchQueue.main.async {
					if !success {
						self?.errorMessage = error?.localizedDescription ?? "Failed to save photo."
					}
				}
			}
		} else if let videoURL = capturedVideoURL {
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
			}) { [weak self] success, error in
				DispatchQueue.main.async {
					if !success {
						self?.errorMessage = error?.localizedDescription ?? "Failed to save video."
					}
				}
			}
		}
	}

	func switchCamera() {
		// Find current video input
		guard let currentInput = session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) else {
			errorMessage = "No current video input."
			return
		}

		let currentPosition = currentInput.device.position
		let desiredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back

		// Find a suitable device for the desired position
		let discovery = AVCaptureDevice.DiscoverySession(
			deviceTypes: [
				.builtInTripleCamera,
				.builtInDualCamera,
				.builtInDualWideCamera,
				.builtInUltraWideCamera,
				.builtInWideAngleCamera,
				.builtInTrueDepthCamera
			],
			mediaType: .video,
			position: desiredPosition
		)

		let chosenDevice = discovery.devices.first
		?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredPosition)

		guard let newDevice = chosenDevice else {
			errorMessage = "Desired camera not available."
			return
		}

		do {
			let newInput = try AVCaptureDeviceInput(device: newDevice)

			session.beginConfiguration()

			// Remove current video input
			session.removeInput(currentInput)

			// Add new input or roll back
			if session.canAddInput(newInput) {
				session.addInput(newInput)
				videoDevice = newDevice
			} else {
				// Roll back to previous input
				if session.canAddInput(currentInput) {
					session.addInput(currentInput)
				}
				session.commitConfiguration()
				errorMessage = "Failed to add new camera input."
				return
			}

			session.commitConfiguration()

			// Rebuild rotation coordinator for the new device
			setupRotationCoordinatorIfPossible()
		} catch {
			errorMessage = error.localizedDescription
		}
	}
}

// MARK: - Photo delegate
extension CameraService: AVCapturePhotoCaptureDelegate {

	func photoOutput(_ output: AVCapturePhotoOutput,
					 didFinishProcessingPhoto photo: AVCapturePhoto,
					 error: Error?) {
		if let error { self.errorMessage = error.localizedDescription; return }
		guard let data = photo.fileDataRepresentation() else {
			self.errorMessage = "No photo data."
			return
		}

		let url = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("jpg")

		do {
			try data.write(to: url, options: .atomic)
			capturedPhotoURL = url
		} catch {
			errorMessage = error.localizedDescription
		}
	}
}

// MARK: - Movie delegate
extension CameraService: AVCaptureFileOutputRecordingDelegate {

	func fileOutput(_ output: AVCaptureFileOutput,
					didFinishRecordingTo outputFileURL: URL,
					from connections: [AVCaptureConnection],
					error: Error?) {
		DispatchQueue.main.async { [weak self] in
			self?.isRecording = false
			if let error {
				self?.errorMessage = error.localizedDescription
			} else {
				self?.capturedVideoURL = outputFileURL
			}
		}
	}
}

