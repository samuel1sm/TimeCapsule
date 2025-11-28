import SwiftUI

struct CaptureMomentView: View {
	var body: some View {
		VStack {
			HStack(alignment: .top, spacing: 12) {
				ZStack {
					Circle()
						.fill(
							LinearGradient(
								colors: [
									Color.purple.opacity(0.9),
									Color.blue.opacity(0.9)
								],
								startPoint: .topLeading,
								endPoint: .bottomTrailing
							)
						)
						.frame(width: 44, height: 44)

					Image(systemName: "sparkles")
						.foregroundStyle(.white)
						.font(.system(size: 20, weight: .semibold))
				}

				VStack(alignment: .leading, spacing: 4) {
					Text("Capture this moment")
						.font(.headline)

					Text("Add your thoughts, photos, or voice notes. This log will be saved automatically at midnight.")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}
			.padding()
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.fill(Color(.systemBackground))
		)
		.overlay(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.stroke(Color.black.opacity(0.05))
		)
	}
}

#Preview {
	CaptureMomentView()
}
