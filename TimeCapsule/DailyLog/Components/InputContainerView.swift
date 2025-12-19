import SwiftUI

struct InputContainerView: View {
	private let initialHeight: CGFloat = 36

	@Binding var thoughtsText: String
	var isFocused: FocusState<Bool>.Binding
	@State private var isSendOptionsExpanded = false
	@State private var moodValue: Double = 0.5
	@State private var isMoodSelected = false
	@State private var currentMood: MoodOptions?
	var sendNote: (EntryModel) -> Void
	@State private var showCamera = false

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			buildMainView().padding(.horizontal)

			if isSendOptionsExpanded || isMoodSelected {
				Divider()
			}

			buildHiddenOptions()
			.padding()
			.frame(height: isSendOptionsExpanded || isMoodSelected ? 140 : 0)

		}
		.padding(.vertical)
		.background(Color(.systemGroupedBackground))
		.onChange(of: isMoodSelected || isSendOptionsExpanded) { _, newValue in
			if newValue {
				isFocused.wrappedValue = false
			}
		}
		.onChange(of: isFocused.wrappedValue) { _, newValue in
			if newValue {
				isSendOptionsExpanded = false
				isMoodSelected = false
			}
		}
	}

	@ViewBuilder
	private func buildMainView() -> some View {
		HStack(alignment: .center) {
			Button {
				isSendOptionsExpanded.toggle()
				isMoodSelected = false
			} label : {
				Image(systemName: "plus")
					.resizable()
					.frame(width: 16, height: 16)
					.transaction { transaction in transaction.animation = nil }
					.foregroundStyle(.black)
			}

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
				.onTapGesture {
					isMoodSelected.toggle()
					isSendOptionsExpanded = false
				}
				.onLongPressGesture(minimumDuration: 0.5) {
					isMoodSelected = false
					isSendOptionsExpanded = false
					currentMood = nil
				}
				.animation(.default, value: currentMood)
				.transaction { transaction in transaction.animation = nil }
			}
			.padding(.leading, 4)
			.padding(.trailing, 6)
			.background(.white)
			.clipShape(RoundedRectangle(cornerRadius: initialHeight))

			HStack(spacing: 20) {
				if thoughtsText.isEmpty {
					Button {
					} label : {
						Image(systemName: "microphone")
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 20)
							.padding(.leading, 4)
					}
					Button {
						showCamera = true
					} label : {
						Image(systemName: "camera")
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 20)
					}
				} else {
					RoundButtonView(systemImageName: "paperplane", colors: [.green]) {
						sendNote(.init(
								entryType: currentMood == nil ? .note : .mood,
								noteModel: .init(note: thoughtsText, mood: currentMood)
						))
						thoughtsText = ""
						currentMood = nil
					}.foregroundStyle(.white)
					.frame(width: initialHeight)
				}
			}
			.foregroundStyle(.black)
			.animation(.default, value: thoughtsText)
		}.sheet(isPresented: $showCamera) {
			CameraView()
		}
	}

	@ViewBuilder
	private func buildHiddenOptions() -> some View {
		VStack {
			if isMoodSelected {
				MoodSliderView(currentMood: $currentMood)
			}

			if isSendOptionsExpanded {
				HStack(alignment: .top, spacing: 24) {
					ForEach(InputOption.allCases) { option in
						RoundButtonView(
							systemImageName: option.systemImageName,
							colors: option.gradientColors,
							text: option.title
						) {
							handleOptionSelection(option)
						}
					}
				}
				.frame(maxHeight: 90)
				.frame(maxWidth: .infinity)
				.tint(.white)
			}
		}
	}

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

				InputContainerView(thoughtsText: $text, isFocused: $focused, sendNote: {_ in })
			}
		}
	}

	static var previews: some View {
		PreviewWrapper()
	}
}
