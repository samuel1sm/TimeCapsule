import SwiftUI

struct ImageToggle: View {
    @Binding var isOn: Bool

    // Optional side labels
    var leftLabel: String? = nil
    var rightLabel: String? = nil

    // Thumb images (inside the moving circle)
    var onThumbImage: Image? = Image(systemName: "checkmark")
    var offThumbImage: Image? = Image(systemName: "xmark")

    // Styling
    var width: CGFloat = 56
    var height: CGFloat = 32
    var padding: CGFloat = 3
    var onColor: Color = .green
    var offColor: Color = .gray.opacity(0.35)
    var thumbColor: Color = .white

    private var thumbSize: CGFloat { height - padding * 2 }
    private var travel: CGFloat { width - padding * 2 - thumbSize }

    var body: some View {
        HStack(spacing: 10) {
            if let leftLabel {
                Text(leftLabel)
                    .font(.subheadline)
					.foregroundStyle(Color.white.opacity(!isOn ? 1 : 0.8))
            }

            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    isOn.toggle()
                }
            } label: {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(isOn ? onColor : offColor)
                        .frame(width: width, height: height)

                    Circle()
                        .fill(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay {
                            (isOn ? onThumbImage : offThumbImage)?
                                .resizable()
                                .scaledToFit()
                                .frame(width: thumbSize * 0.55, height: thumbSize * 0.55)
                                .foregroundStyle(.primary)
                        }
                        .shadow(radius: 1.5, y: 1)
                        .offset(x: padding + (isOn ? travel : 0))
                }
                .contentShape(Rectangle()) // makes the whole area tappable
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Toggle")
            .accessibilityValue(isOn ? "On" : "Off")

            if let rightLabel {
                Text(rightLabel)
                    .font(.subheadline)
					.foregroundStyle(Color.white.opacity(isOn ? 1 : 0.8))
            }
        }
    }
}

#Preview {
	struct PreviewWrapper: View {
		@State private var enabled1 = false
		@State private var enabled2 = true

		var body: some View {
			VStack(spacing: 24) {
				ImageToggle(
					isOn: $enabled1,
					leftLabel: "Off",
					rightLabel: "On",
					onThumbImage: Image(systemName: "sun.max.fill"),
					offThumbImage: Image(systemName: "moon.fill"),
					onColor: .blue,
					offColor: .gray.opacity(0.25)
				)

				ImageToggle(
					isOn: $enabled2,
					leftLabel: "No",
					rightLabel: "Yes",
					onThumbImage: Image(systemName: "checkmark"),
					offThumbImage: Image(systemName: "xmark"),
					onColor: .green,
					offColor: .red.opacity(0.25)
				)

				ImageToggle(isOn: $enabled1)
			}
			.padding()
		}
	}

	return PreviewWrapper()
}






