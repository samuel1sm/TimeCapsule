import SwiftUI
import AVFoundation

final class PreviewView: UIView {

	override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
	var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

struct CameraRepresentable: UIViewRepresentable {
	let session: AVCaptureSession
	let onPreviewLayer: (AVCaptureVideoPreviewLayer) -> Void

	func makeUIView(context: Context) -> PreviewView {
		let view = PreviewView()
		view.videoPreviewLayer.session = session
		view.videoPreviewLayer.videoGravity = .resizeAspectFill
		onPreviewLayer(view.videoPreviewLayer)
		return view
	}

	func updateUIView(_ uiView: PreviewView, context: Context) {}
}
