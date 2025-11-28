import SwiftUI

struct EmptyCapsulesView: View {

	var onCreateClicked: () -> Void

	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: "archivebox")
				.font(.system(size: 52, weight: .regular))
				.foregroundStyle(.secondary)

			VStack(spacing: 6) {
				Text("No Capsules Yet")
					.font(.title3).bold()
				Text("Start by creating your first time capsule.")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			Button(action: onCreateClicked) {
				HStack(spacing: 8) {
					Image(systemName: "plus.circle.fill")
					Text("Create New Capsule")
						.fontWeight(.semibold)
				}
				.frame(height: 50)
				.frame(maxWidth: .infinity)
			}
			.buttonStyle(.sealCapsuleGradient)
			.tint(.pink)
			.padding(.top, 8)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.fill(Color(.secondarySystemGroupedBackground))
		)
	}
}

#Preview {
	EmptyCapsulesView { }
//		.padding()
}
