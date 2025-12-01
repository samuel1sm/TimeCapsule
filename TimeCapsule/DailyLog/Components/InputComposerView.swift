import SwiftUI

struct InputComposerView: View {
    @Binding var text: String
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

				TextEditor(text: $text)
					.focused(isFocused)
					.scrollContentBackground(.hidden)
					.background(.white)
					.clipShape(RoundedRectangle(cornerRadius: initialHeight))
					.frame(minHeight: initialHeight, maxHeight: 120)
					.fixedSize(horizontal: false, vertical: true)

				
				if text.isEmpty {
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

// MARK: - Subviews

struct TopPillButton: View {
    let icon: String
    let title: String
    var isPrimary: Bool
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isPrimary {
                        if isActive {
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color(.systemGray6)
                        }
                    } else {
                        Color(.systemGray6)
                    }
                }
            )
            .foregroundStyle(isPrimary && isActive ? Color.white : Color.primary.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryPillButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .font(.footnote)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct InputComposerView_Previews: PreviewProvider {
    struct Host: View {
        @State private var text = "teste"
        @FocusState private var focused: Bool
        var body: some View {
            InputComposerView(text: $text, isFocused: $focused)
        }
    }

    static var previews: some View {
        Host()
    }
}
