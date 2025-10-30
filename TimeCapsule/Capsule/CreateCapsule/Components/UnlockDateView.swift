import SwiftUI

struct UnlockDateView: View {
	@Binding var unlockDate: Date

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Unlock Date & Time")
				.font(.headline)
			HStack {
				DatePicker(
					"Choose when you want to open this capsule",
					selection: $unlockDate,
					displayedComponents: .date
				)
				.frame(maxWidth: .infinity)
				.labelsHidden()
				.padding()
				Divider()
				DatePicker(
					"Choose when you want to open this capsule",
					selection: $unlockDate,
					displayedComponents: .hourAndMinute
				)
				.frame(maxWidth: .infinity)
				.labelsHidden()
				.padding()
			}
			.background(Color(.systemGray6))
			.cornerRadius(10)
		}
	}
}

#Preview {
	UnlockDateView(unlockDate: .constant(.now))
}
