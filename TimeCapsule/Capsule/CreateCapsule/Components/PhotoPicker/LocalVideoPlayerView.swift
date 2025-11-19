import SwiftUI
import AVKit

struct LocalVideoPlayerView: View {
	@State private var isLoading = true
	private let model: SelectedMediaModel
	@State private var player: AVPlayer?
	
	init(model: SelectedMediaModel) {
		self.model = model
		if model.type == .video {
			let p = AVPlayer(url: model.url)
			p.isMuted = true
			_player = State(initialValue: p)
		}
	}
	
	var body: some View {
		ZStack {
			if isLoading {
				ProgressView()
					.progressViewStyle(.circular)
			}
			
			if let player, model.type == .video {
				VideoPlayer(player: player)
					.allowsHitTesting(false)
					.onAppear {
						isLoading = false
					}
			} else if model.type == .image {
				LocalFileImage(url: model.url)
					.scaledToFill()
					.onAppear { isLoading = false }
			}
		}
		.onAppear {
			if model.type == .video && player == nil {
				let p = AVPlayer(url: model.url)
				p.isMuted = true
				player = p
			}
			player?.isMuted = true
			player?.play()
		}
		.onDisappear {
			player?.pause()
		}
	}
}

#Preview {
	LocalVideoPlayerView(
		model: .init(
			type: .image,
			url: URL(string: "https://live.staticflickr.com/9/8865/17270333843_bb7eae34ef_z.jpg")!,
			identifier: 0
		)
	)
}
