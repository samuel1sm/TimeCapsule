import SwiftUI

struct DailyLogHeaderView: View {
	let todayString: String
	@Binding var closesTimeText: String

	var body: some View {
		VStack(alignment: .trailing, spacing: 8) {
			HStack(alignment: .bottom, spacing: 0) {
				Text("Today's Log")
					.font(.title3.weight(.semibold))
				Spacer()
				Text(todayString)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			HStack(spacing: 8) {
				Image(systemName: "clock")
					.font(.subheadline.weight(.semibold))

				Text("Closes in \(closesTimeText)")
					.font(.subheadline.weight(.semibold))
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 8)
			.background(
				Capsule()
					.fill(Color.orange.opacity(0.1))
			)
			.foregroundStyle(Color.orange)
		}
	}
}

#Preview {
	DailyLogHeaderView(
		todayString: "Friday, November 28, 2025",
		closesTimeText: .constant( "07:13:42")
	)
	.padding()
}
