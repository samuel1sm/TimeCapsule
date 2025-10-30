import SwiftUI

struct CreateCapsule: View {
	@State private var title: String = ""
	@State private var message: String = ""
	@State private var unlockDate = Date()
	@State private var isPrivate = true
	@State private var showMediaPicker = false
	@State private var selectedMedia: [UIImage] = []

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				VStack(alignment: .leading, spacing: 8) {
					Text("Capsule Title")
						.font(.headline)
					TextField(
						"",
						text: $title,
						prompt: Text("e.g., Dear Future Me").foregroundStyle(.gray)
					)
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(10)
				}

				VStack(alignment: .leading, spacing: 8) {
					Text("Your Message").font(.headline)
					TextEditor(text: $message)
						.frame(height: 120)
						.scrollContentBackground(.hidden)
						.padding(8)
						.background(Color(.systemGray6))
						.cornerRadius(10)
						.overlay(
							Group {
								if message.isEmpty {
									Text("Write a note to your future self or describe this moment...")
										.foregroundColor(.gray)
										.padding(16)
										.allowsHitTesting(false)
								}
							},
							alignment: .topLeading
						)
				}

				PhotosAndVideosView(showMediaPicker: $showMediaPicker)

				UnlockDateView(unlockDate: $unlockDate)

				PrivacySettingsView(isPrivate: $isPrivate)
			}
			.padding()
		}
		.navigationTitle("Create Capsule")
		.sheet(isPresented: $showMediaPicker) {
			Text("Media picker placeholder")
		}
	}
}

#Preview {
	CreateCapsule()
}
