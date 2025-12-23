import SwiftUI

struct MediaLoadingView: View {
	let progress: Double

	var body: some View {
		VStack(spacing: 16) {
			if progress <= 0 {
				// Initial phase: unknown progress -> circular spinner
				ProgressView()
					.progressViewStyle(.circular)
					.tint(.white)
				Text("Processing video...")
					.font(.headline)
					.foregroundStyle(.white)
			} else {
				// Progress known: show linear bar and percentage
				ZStack(alignment: .leading) {
					RoundedRectangle(cornerRadius: 8)
						.fill(Color.white.opacity(0.2))
						.frame(width: 240, height: 12)
					RoundedRectangle(cornerRadius: 8)
						.fill(Color.white)
						.frame(width: 240 * progress, height: 12)
						.animation(.easeInOut(duration: 0.1), value: progress)
				}
				Text("Processing video... \(Int(progress * 100))%")
					.font(.headline)
					.foregroundStyle(.white)
			}
		}
		.padding(24)
		.background(Color.black.opacity(0.7))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
}
