import SwiftUI

struct PrivacySettingsView: View {
	@Binding var isPrivate: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Privacy Settings")
				.font(.headline)
			HStack(spacing: 12) {
				Button(action: { isPrivate = true }) {
					VStack {
						Image(systemName: "lock.fill")
						Text("Private")
					}
					.frame(maxWidth: .infinity)
					.padding()
					.background(isPrivate ? Color.purple.opacity(0.1) : Color(.systemGray6))
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(isPrivate ? Color.purple : Color.clear, lineWidth: 2)
					)
					.cornerRadius(12)
				}
				Button(action: { isPrivate = false }) {
					VStack {
						Image(systemName: "person.2")
						Text("Shareable")
					}
					.frame(maxWidth: .infinity)
					.padding()
					.background(!isPrivate ? Color.purple.opacity(0.1) : Color(.systemGray6))
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(!isPrivate ? Color.purple : Color.clear, lineWidth: 2)
					)
					.cornerRadius(12)
				}
			}
		}
	}
}

#Preview {
	PrivacySettingsView(isPrivate: .constant(true))
}
