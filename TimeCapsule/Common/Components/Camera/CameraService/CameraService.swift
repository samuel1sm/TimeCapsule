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

	// Segmented recording state
	private var segmentURLs: [URL] = []
	private var pendingStopFinalizeAndMerge = false
	private var activeSegmentCount = 0

	// Serialized camera switch state
	private var pendingSwitchPosition: AVCaptureDevice.Position?
	private var isSwitchingCameras = false

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
			self?.session.startRunning()
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
		let settings = AVCapturePhotoSettings()
		photoOutput.capturePhoto(with: settings, delegate: self)
	}

	func toggleRecording() {
		if isRecording {
			// Stop the entire session; merge after the last segment finalizes.
			pendingStopFinalizeAndMerge = true
			movieOutput.stopRecording()
			return
		}

		// Start new session
		segmentURLs.removeAll()
		pendingStopFinalizeAndMerge = false
		isSwitchingCameras = false
		pendingSwitchPosition = nil

		startNewSegment()
		isRecording = true
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
				return
			}

			// If user requested stop of entire session and no active segments remain, merge
			if self.pendingStopFinalizeAndMerge, self.activeSegmentCount == 0 {
				self.isRecording = false
				self.mergeSegmentsAndFinish()
			}
		}
	}

	private func mergeSegmentsAndFinish() {
		let segments = segmentURLs
		guard !segments.isEmpty else {
			errorMessage = "No segments to merge."
			return
		}

		if segments.count == 1 {
			capturedVideoURL = segments[0]
			segmentURLs.removeAll()
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
				await MainActor.run { self.errorMessage = "Failed to create composition tracks." }
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
						await MainActor.run { self.errorMessage = "Merge failed (video): \(error.localizedDescription)" }
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
						await MainActor.run { self.errorMessage = "Merge failed (audio): \(error.localizedDescription)" }
						return
					}
				}

				currentTime = try await CMTimeAdd(currentTime, asset.load(.duration))
			}

			// Preserve transform for orientation
			videoTrack.preferredTransform = videoTransform

			guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
				await MainActor.run { self.errorMessage = "Failed to create exporter." }
				return
			}
			exporter.outputURL = outputURL
			exporter.outputFileType = .mov
			exporter.shouldOptimizeForNetworkUse = true

			await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
				exporter.exportAsynchronously {
					continuation.resume()
				}
			}

			await MainActor.run {
				if exporter.status == .completed {
					self.capturedVideoURL = outputURL
					for url in segments { try? FileManager.default.removeItem(at: url) }
				} else {
					self.errorMessage = exporter.error?.localizedDescription ?? "Export failed."
				}
				self.segmentURLs.removeAll()
			}
		}
	}
}
