import Foundation
import AVFoundation
import Photos
import SwiftUI
import Combine

enum CameraServiceError: String, Error {

	case noMidiaToSave = "No current video input."
	case saveError = "Failed to save media"
}

@MainActor
final class CameraService: NSObject, ObservableObject {

	// Public state
	@Published var isRecording = false
	@Published var capturedPhotoURL: URL?
	@Published var capturedVideoURL: URL?
	@Published var errorMessage: String?
	@Published var isProcessing = false
	@Published var processingProgress: Double = 0.0

	// Flash/Torch state
	@Published var flashMode: AVCaptureDevice.FlashMode = .off
	@Published var isFlashTorchAvailable = false

	@Published var isFlashAvailable: Bool = false
	@Published var isTorchAvailable: Bool = false

	let session = AVCaptureSession()

	private let photoOutput = AVCapturePhotoOutput()
	private let movieOutput = AVCaptureMovieFileOutput()

	private var videoDevice: AVCaptureDevice? {
		didSet {
			isFlashAvailable = videoDevice?.hasFlash == true
			isTorchAvailable = videoDevice?.hasTorch == true
		}
	}

	private var previewLayer: AVCaptureVideoPreviewLayer?
	private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
	private var previewAngleObservation: NSKeyValueObservation?
	private var captureAngleObservation: NSKeyValueObservation?

	// Segmented recording state
	private var segmentURLs: [URL] = []
	private var pendingStopFinalizeAndMerge = false
	private var activeSegmentCount = 0

	// Serialized camera switch state
	private var pendingSwitchPosition: AVCaptureDevice.Position?
	private var isSwitchingCameras = false

	// MARK: - Permissions + lifecycle

	func start() {
		// If the session already has inputs configured, don't reconfigure; just start running.
		if !session.inputs.isEmpty {
			Task.detached { [weak self] in
				await self?.session.startRunning()
			}
		} else {
			Task { await requestPermissionsAndConfigure() }
		}
	}

	func stop() {
		Task { @MainActor [weak self] in
			// Ensure torch is off when stopping the session
			self?.setTorchMode(.off)
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
		configureSession()

		Task.detached { [weak self] in
			await self?.session.startRunning()
		}
	}

	// MARK: - Session config

	private func configureSession() {
		session.beginConfiguration()
		session.sessionPreset = .high

		// Reuse existing video input if present; otherwise add one.
		if let existingVideoInput = session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) {
			videoDevice = existingVideoInput.device
		} else {
			guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
				  let videoInput = try? AVCaptureDeviceInput(device: camera),
				  session.canAddInput(videoInput)
			else {
				finishConfigWithError("Failed to add video input.")
				return
			}
			session.addInput(videoInput)
			videoDevice = camera
		}

		// Audio input (needed for movie recording audio) — add only if missing
		let hasAudioInput = session.inputs.compactMap { $0 as? AVCaptureDeviceInput }.contains { $0.device.hasMediaType(.audio) }
		if !hasAudioInput {
			if let mic = AVCaptureDevice.default(for: .audio),
			   let audioInput = try? AVCaptureDeviceInput(device: mic),
			   session.canAddInput(audioInput) {
				session.addInput(audioInput)
			}
		}

		// Photo output — add only if not already added
		let hasPhotoOutput = session.outputs.contains { $0 === photoOutput }
		if !hasPhotoOutput, session.canAddOutput(photoOutput) {
			session.addOutput(photoOutput)
		}

		// Movie output — add only if not already added
		let hasMovieOutput = session.outputs.contains { $0 === movieOutput }
		if !hasMovieOutput, session.canAddOutput(movieOutput) {
			session.addOutput(movieOutput)
		}

		session.commitConfiguration()

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

		let currentPreviewLayer = previewLayer
		let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: currentPreviewLayer)
		rotationCoordinator = coordinator

		previewAngleObservation = coordinator.observe(
			\.videoRotationAngleForHorizonLevelPreview,
			 options: [.initial, .new]
		) { [weak self] _, change in
			guard let angle = change.newValue else { return }
			Task { @MainActor [weak self] in
				guard let connection = self?.previewLayer?.connection,
					  connection.isVideoRotationAngleSupported(angle) else { return }
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
		// If recording, cancel it first, and clear any pending merge/switch state.
		if isRecording {
			pendingStopFinalizeAndMerge = false
			isSwitchingCameras = false
			pendingSwitchPosition = nil
			movieOutput.stopRecording()
			isRecording = false
			segmentURLs.removeAll()
			activeSegmentCount = 0
			// Turn torch off when leaving video mode
			setTorchMode(.off)
		}

		let settings = AVCapturePhotoSettings()
		// Apply flash for still photos if available
		if isFlashAvailable {
			settings.flashMode = flashMode
		}
		photoOutput.capturePhoto(with: settings, delegate: self)
	}

	func toggleRecording() {
		if isRecording {
			// Stop the entire session; merge after the last segment finalizes.
			pendingStopFinalizeAndMerge = true
			movieOutput.stopRecording()
			// Ensure torch is off when stopping
			setTorchMode(.off)
			return
		}

		// Start new session
		segmentURLs.removeAll()
		pendingStopFinalizeAndMerge = false
		isSwitchingCameras = false
		pendingSwitchPosition = nil

		startNewSegment()
		isRecording = true
		// Apply torch according to current flashMode when recording starts
		applyTorchForCurrentModeIfNeeded()
	}

	private func startNewSegment() {
		let url = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("mov")
		activeSegmentCount += 1
		movieOutput.startRecording(to: url, recordingDelegate: self)
	}

	func discardCapture() {
		capturedPhotoURL = nil
		capturedVideoURL = nil
	}

	func saveCaptureToPhotos(resut: @escaping (MediaTypes, URL) -> Void) {

		Task { @MainActor [resut, weak self] in
			guard let self else { return }

			// Decide what to save before calling performChanges (non-throwing closure).
			let photoURL = self.capturedPhotoURL
			let videoURL = self.capturedVideoURL

			guard photoURL != nil || videoURL != nil else {
				self.errorMessage = CameraServiceError.noMidiaToSave.rawValue
				return
			}

			do {
				try await PHPhotoLibrary.shared().performChanges {
					if let url = photoURL {
						PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
						resut(.image, url)
					} else if let url = videoURL {
						PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
						resut(.video, url)
					}
				}
			} catch {
				self.errorMessage = CameraServiceError.saveError.rawValue
			}
		}
	}

	// MARK: - Camera switching (serialized while recording)

	func switchCamera() {
		// Find current video input
		guard let currentInput = session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) else {
			errorMessage = "No current video input."
			return
		}

		let currentPosition = currentInput.device.position
		let desiredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back

		// If already switching, ignore repeated taps
		if isSwitchingCameras {
			return
		}

		if isRecording {
			// Defer the actual switch until the current segment is finalized
			isSwitchingCameras = true
			pendingSwitchPosition = desiredPosition
			// This will trigger didFinishRecording; don't reconfigure yet
			movieOutput.stopRecording()
			return
		}

		// Not recording: perform immediate switch
		performCameraSwitch(to: desiredPosition)
	}

	private func performCameraSwitch(to position: AVCaptureDevice.Position) {
		// Choose a device for the desired position
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
			position: position
		)

		let chosenDevice = discovery.devices.first
			?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)

		guard let newDevice = chosenDevice else {
			errorMessage = "Desired camera not available."
			return
		}

		// Find current video input
		guard let currentVideoInput = session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) else {
			errorMessage = "No current video input."
			return
		}

		do {
			let newInput = try AVCaptureDeviceInput(device: newDevice)

			session.beginConfiguration()
			session.removeInput(currentVideoInput)

			if session.canAddInput(newInput) {
				session.addInput(newInput)
				videoDevice = newDevice
			} else {
				// Roll back
				if session.canAddInput(currentVideoInput) {
					session.addInput(currentVideoInput)
				}
				session.commitConfiguration()
				errorMessage = "Failed to add new camera input."
				return
			}

			session.commitConfiguration()

			setupRotationCoordinatorIfPossible()
			// Re-apply torch after switching cameras if recording
			applyTorchForCurrentModeIfNeeded()
		} catch {
			errorMessage = error.localizedDescription
		}
	}

	// MARK: - Flash/Torch controls

	func cycleFlashMode() {
		switch flashMode {
		case .off:
			flashMode = .on
		case .on:
			flashMode = .auto
		case .auto:
			flashMode = .off
		@unknown default:
			flashMode = .off
		}
		// If recording video, update torch to reflect new mode
		applyTorchForCurrentModeIfNeeded()
	}

	func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
		flashMode = mode
		applyTorchForCurrentModeIfNeeded()
	}

	private func applyTorchForCurrentModeIfNeeded() {
		// Torch (continuous light) is only relevant for video recording.
		guard isRecording else {
			setTorchMode(.off)
			return
		}
		switch flashMode {
		case .off:
			setTorchMode(.off)
		case .on:
			setTorchMode(.on)
		case .auto:
			setTorchMode(.auto)
		@unknown default:
			setTorchMode(.off)
		}
	}

	private func setTorchMode(_ mode: AVCaptureDevice.TorchMode) {
		guard let device = videoDevice, device.hasTorch else { return }
		do {
			try device.lockForConfiguration()
			if device.isTorchModeSupported(mode) {
				device.torchMode = mode
			} else {
				device.torchMode = .off
			}
			device.unlockForConfiguration()
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
			guard let self else { return }

			// Close this segment
			self.activeSegmentCount = max(0, self.activeSegmentCount - 1)

			// If we were switching cameras, ignore benign interruptions unless we truly failed to produce a file
			if let error, !self.isSwitchingCameras {
				self.errorMessage = error.localizedDescription
			}

			// Append valid segment
			if (try? FileManager.default.attributesOfItem(atPath: outputFileURL.path)[.size] as? NSNumber)?.intValue ?? 0 > 0 {
				self.segmentURLs.append(outputFileURL)
			} else {
				try? FileManager.default.removeItem(at: outputFileURL)
			}

			// If a camera switch was pending and no active segments, perform it now and start a new segment
			if self.isSwitchingCameras, self.activeSegmentCount == 0 {
				let target = self.pendingSwitchPosition
				self.isSwitchingCameras = false
				self.pendingSwitchPosition = nil

				if let target {
					self.performCameraSwitch(to: target)
				}
				// Immediately start next segment to continue recording
				self.startNewSegment()
				self.isRecording = true
				// Apply torch according to flashMode after resuming recording
				self.applyTorchForCurrentModeIfNeeded()
				return
			}

			// If user requested stop of entire session and no active segments remain, merge
			if self.pendingStopFinalizeAndMerge, self.activeSegmentCount == 0 {
				self.isRecording = false
				// Ensure torch is off when recording stops
				self.setTorchMode(.off)
				self.mergeSegmentsAndFinish()
			}
		}
	}

	private func mergeSegmentsAndFinish() {
		let segments = segmentURLs
		if segments.isEmpty {
			errorMessage = "No segments to merge."
			return
		}

		// Indicate processing has started
		isProcessing = true
		processingProgress = 0.0

		if segments.count == 1 {
			capturedVideoURL = segments[0]
			segmentURLs.removeAll()
			isProcessing = false
			processingProgress = 1.0
			return
		}

		let outputURL = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("mov")

		Task.detached(priority: .userInitiated) { [segments] in
			let composition = AVMutableComposition()
			guard
				let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
				let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
			else {
				await MainActor.run {
					self.errorMessage = "Failed to create composition tracks."
					self.isProcessing = false
					self.processingProgress = 0.0
				}
				return
			}

			var currentTime = CMTime.zero
			var videoTransform: CGAffineTransform = .identity

			for url in segments {
				let asset = AVURLAsset(url: url)

				if let srcVideoTrack = try? await asset.loadTracks(withMediaType: .video).first,
				   let transform = try? await srcVideoTrack.load(.preferredTransform) {
					videoTransform = transform
					do {
						try await videoTrack.insertTimeRange(
							CMTimeRange(start: .zero, duration: asset.load(.duration)),
							of: srcVideoTrack,
							at: currentTime
						)
					} catch {
						await MainActor.run {
							self.errorMessage = "Merge failed (video): \(error.localizedDescription)"
							self.isProcessing = false
							self.processingProgress = 0.0
						}
						return
					}
				}

				if let srcAudioTrack = try? await asset.loadTracks(withMediaType: .audio).first {
					do {
						try await audioTrack.insertTimeRange(
							CMTimeRange(start: .zero, duration: asset.load(.duration)),
							of: srcAudioTrack,
							at: currentTime
						)
					} catch {
						await MainActor.run {
							self.errorMessage = "Merge failed (audio): \(error.localizedDescription)"
							self.isProcessing = false
							self.processingProgress = 0.0
						}
						return
					}
				}

				currentTime = try await CMTimeAdd(currentTime, asset.load(.duration))
			}

			// Preserve transform for orientation
			videoTrack.preferredTransform = videoTransform

			guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
				await MainActor.run {
					self.errorMessage = "Failed to create exporter."
					self.isProcessing = false
					self.processingProgress = 0.0
				}
				return
			}
			exporter.shouldOptimizeForNetworkUse = true

			Task { [weak self] in
				guard let self else { return }
				do {
					try await exporter.export(to: outputURL, as: .mov)

					// Delete segments OFF the main thread
					for url in segments {
						try? FileManager.default.removeItem(at: url)
					}

					// UI/state updates ON the main thread
					await MainActor.run {
						self.capturedVideoURL = outputURL
						self.segmentURLs.removeAll()
						self.isProcessing = false
						self.processingProgress = 1.0
					}
				} catch {
					await MainActor.run {
						self.errorMessage = error.localizedDescription
						self.segmentURLs.removeAll()
						self.isProcessing = false
						self.processingProgress = 0.0
					}
				}
			}

			for await state in exporter.states(updateInterval: 0.1) {
				if case .exporting(let progress) = state {
					await MainActor.run {
						self.processingProgress = min(max(progress.fractionCompleted, 0.0), 1.0)
					}
				}
			}
		}
	}
}
