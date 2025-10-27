import SwiftUI

struct CapsuleCard: View {
	let item: CapsuleItem
	let imageUrlString = "https://live.staticflickr.com/9/8865/17270333843_bb7eae34ef_z.jpg"
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			AsyncImage(url: URL(string: imageUrlString)) { phase in
				switch phase {
				case .empty:
					ProgressView()
				case .success(let image):
					image
						.resizable()
						.scaledToFill()
				case .failure:
					Image(systemName: "photo")
						.resizable()
						.scaledToFit()
						.foregroundColor(.gray)
				@unknown default:
					EmptyView()
				}
			}.frame(height: 220)
				.clipped()
				.overlay(
					// Subtle gradient to ensure legibility
					LinearGradient(
						colors: [Color.black.opacity(0.6), .clear],
						startPoint: .bottom,
						endPoint: .top
					)
				)
				.clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

			VStack(alignment: .leading, spacing: 8) {
				Text(item.title)
					.font(.title3).bold()
					.foregroundStyle(.white)
					.shadow(radius: 3)

				HStack(spacing: 8) {
					Image(systemName: "clock")
						.foregroundStyle(.white.opacity(0.9))
					Text("Opens in \(item.timeRemainingString())")
						.foregroundStyle(.white.opacity(0.9))
						.font(.subheadline)
				}
			}
			.padding(20)
		}
		.contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
		.shadow(color: .black.opacity(0.12), radius: 16, y: 8)
	}
}
#Preview {
	CapsuleCard(item: .init(title: "teste", openDate: .now, imageName: "home"))
}
