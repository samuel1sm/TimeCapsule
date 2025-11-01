import SwiftUI

struct CreateCapsule: View {
	@State private var viewModel = CreateCapsuleViewModel()

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {

				VStack(alignment: .leading, spacing: 8) {
					Text("Capsule Title").font(.headline)
					TextField("", text: $viewModel.title,
							  prompt: Text("e.g., Dear Future Me").foregroundStyle(.gray))
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(10)
				}

				// Message
				VStack(alignment: .leading, spacing: 8) {
					Text("Your Message").font(.headline)
					TextEditor(text: $viewModel.message)
						.frame(height: 120)
						.scrollContentBackground(.hidden)
						.padding(8)
						.background(Color(.systemGray6))
						.cornerRadius(10)
						.overlay (
							Group {
								if viewModel.message.isEmpty {
									Text("Write a note to your future self or describe this moment...")
										.foregroundColor(.gray)
										.padding(16)
										.allowsHitTesting(false)
								}
							},
							alignment: .topLeading
						)
				}

				PhotosAndVideosView(showMediaPicker: $viewModel.showMediaPicker)
				UnlockDateView(unlockDate: $viewModel.unlockDate)
				PrivacySettingsView(isPrivate: $viewModel.isPrivate)

				Button { viewModel.seal() } label: {
					HStack { Text("Seal Capsule") }
						.frame(height: 60)
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.sealCapsuleGradient)
				.disabled(!viewModel.canSeal)
			}
			.padding()
		}
		.navigationTitle("Create Capsule")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button{ viewModel.reset() } label:  {
					Image(systemName: "arrow.trianglehead.counterclockwise")
				}
			}
		}
		.sheet(isPresented: $viewModel.showMediaPicker) {
			Text("Media picker placeholder")
		}
	}
}

#Preview {
	CreateCapsule()
}
