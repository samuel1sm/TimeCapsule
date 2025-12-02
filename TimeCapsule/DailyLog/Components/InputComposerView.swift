import SwiftUI

struct InputComposerView: View {
	@Binding var thoughtsText: String
	var isFocused: FocusState<Bool>.Binding

	@State private var isExpanded = false
	@State private var includeLocation = false
	@State private var moodValue: Double = 0.5
	private let initialHeight: CGFloat = 36

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// Text input
			HStack(alignment: .top) {
				RoundButtonView(colors: []) {
				}
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
								Text("Write your toughts")
									.foregroundColor(Color(.placeholderText))
									.padding(.horizontal, 4)
							}
						}
				}.padding(.horizontal)
					.background(.white)
					.clipShape(RoundedRectangle(cornerRadius: initialHeight))

				Group {
					if thoughtsText.isEmpty {
						RoundButtonView(systemImageName: "microphone", colors: []) {
						}
						.foregroundStyle(.black)
						.frame(width: initialHeight)

						RoundButtonView(systemImageName: "camera", colors: []) {
						}
						.foregroundStyle(.black)
						.frame(width: initialHeight)
					} else {
						RoundButtonView(systemImageName: "paperplane", colors: [.green]) {
						}
						.foregroundStyle(.white)
						.frame(width: initialHeight)
					}
				}
			}.animation(.default, value: thoughtsText)
		}
		.padding()
		.background(Color(.systemGroupedBackground))
	}

	private var moodEmoji: String {
		switch moodValue {
		case ..<0.25:  return "☹️"
		case ..<0.5:   return "😕"
		case ..<0.75:  return "🙂"
		default:       return "😄"
		}
	}
}

// MARK: - Preview

struct InputComposerView_Previews: PreviewProvider {
    struct Host: View {
        @State private var text = ""
        @FocusState private var focused: Bool
        var body: some View {
            InputComposerView(thoughtsText: $text, isFocused: $focused)
        }
    }

    static var previews: some View {
        Host()
    }
}
