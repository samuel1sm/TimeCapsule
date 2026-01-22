import SwiftUI

struct MoreItemsInformationCell: View {

	let extra: Int

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12, style: .continuous)
				.fill(Color.secondary.opacity(0.18))
				.frame(width: 80, height: 80)
			Color.black.opacity(0.4)
				.cornerRadius(12)
			Text("+\(extra)")
				.foregroundColor(.white)
				.font(.title.bold())
				.shadow(radius: 3)
		}
		.frame(width: 80, height: 80)
	}
}

#Preview {
	MoreItemsInformationCell(extra: 4)
		.padding()
		.previewLayout(.sizeThatFits)
}
