import SwiftUI
import AVKit

struct LocalVideoPlayerView: View {
	@State private var isLoading = true
	private let model: SelectedMediaModel
	@State private var player: AVPlayer?

	init(model: SelectedMediaModel) {
		self.model = model
		if model.type == .video {
			_player = State(initialValue: AVPlayer(url: model.url))
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
					.disabled(false)
					.onAppear {
						isLoading = false
					}
			} else if model.type == .image {
				AsyncImage(url: model.url) { phase in
					if case let .success(image) = phase {
						image
						.resizable()
						.scaledToFill()
						.onAppear {
							isLoading = false
						}
					} else {
						ProgressView()
							.progressViewStyle(.circular)
							.onAppear {
								isLoading = false
							}
					}
				}
			}
		}
		.onAppear {
			if model.type == .video && player == nil {
				player = AVPlayer(url: model.url)
			}
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
			url: URL(string: "https://live.staticflickr.com/9/8865/17270333843_bb7eae34ef_z.jpg")!
		)
	)
}
