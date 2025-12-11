import SwiftUI

struct InputContainerView: View {

	@Binding var thoughtsText: String
	var isFocused: FocusState<Bool>.Binding

	@State private var isExpanded = false
	@State private var includeLocation = false
	@State private var moodValue: Double = 0.5
	private let initialHeight: CGFloat = 36
	@State private var isMoodSelected = false
	@State private var currentMood: MoodOptions?

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// MARK: - Top Input Bar
			HStack(alignment: .top) {
				RoundButtonView(colors: []) {}
					.foregroundStyle(.black)
					.frame(width: initialHeight)

				HStack {
					TextEditor(text: $thoughtsText)
						.focused(isFocused)
						.scrollContentBackground(.hidden)
						.background(.white)
						.frame(minHeight: initialHeight, maxHeight: 120)
						.fixedSize(horizontal: false, vertical: true)
						.overlay(alignment: .leading) {
							if thoughtsText.isEmpty {
								Text("Write your thoughts")
									.foregroundColor(Color(.placeholderText))
									.padding(.horizontal, 4)
							}
						}

					VStack {
						if let emoji = currentMood?.emoji {
							Text(emoji)
						} else {
							Circle()
								.stroke(
									Color.yellow,
									style: StrokeStyle(
										lineWidth: 2,
										dash: [6, 4]
									)
								)
								.frame(width: 20, height: 20)
						}
					}
					.frame(width: 24, height: 24)
					.contentShape(Rectangle())
					.onTapGesture { isMoodSelected.toggle() }
					.onLongPressGesture(minimumDuration: 0.5) {
						isMoodSelected = false
						currentMood = nil
					}
					.animation(.default, value: currentMood)
					.transaction { transaction in transaction.animation = nil }
				}
				.padding(.leading, 4)
				.padding(.trailing, 6)
				.background(.white)
				.clipShape(RoundedRectangle(cornerRadius: initialHeight))

				HStack {
					if thoughtsText.isEmpty {
						RoundButtonView(systemImageName: "microphone", colors: []) {}
							.foregroundStyle(.black)
							.frame(width: initialHeight)

						RoundButtonView(systemImageName: "camera", colors: []) {}
							.foregroundStyle(.black)
							.frame(width: initialHeight)
					} else {
						RoundButtonView(systemImageName: "paperplane", colors: [.green]) {}
							.foregroundStyle(.white)
							.frame(width: initialHeight)
					}
				}.animation(.default, value: thoughtsText)
			}
			.padding(.horizontal)

			Divider()
			VStack {
				if isMoodSelected {
					MoodSliderView(currentMood: $currentMood)
				} else {
					HStack(spacing: 16) {
						ForEach(InputOption.allCases) { option in
							InputOptionView(option: option) {
								handleOptionSelection(option)
							}
						}
					}
					.frame(maxWidth: .infinity)
					.tint(.white)
				}
			}
			.padding()
			.frame(height: 140)

		}
		.padding(.vertical)
		.background(Color(.systemGroupedBackground))
	}

	// Helper to handle actions neatly
	private func handleOptionSelection(_ option: InputOption) {
		switch option {
		case .camera:
			print("Camera tapped")
		case .gallery:
			print("Gallery tapped")
		case .documents:
			print("Documents tapped")
		case .location:
			print("Location tapped")
		}
	}
}

struct InputComposerView_Previews: PreviewProvider {
	struct PreviewWrapper: View {
		@State var text = ""
		@FocusState var focused: Bool

		var body: some View {
			ZStack(alignment: .bottom) {
				Color.white.ignoresSafeArea()

				InputContainerView(thoughtsText: $text, isFocused: $focused)
			}
		}
	}

	static var previews: some View {
		PreviewWrapper()
	}
}
