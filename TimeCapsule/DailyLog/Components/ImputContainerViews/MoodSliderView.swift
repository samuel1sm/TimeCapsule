import SwiftUI

struct MoodSliderView: View {
    // State variable to hold the slider's value, ranging from 0.0 to 1.0.
    @State private var sliderValue: Double = 0.5
    @Binding var currentMood: MoodOptions?

    var body: some View {
        VStack(spacing: 20) {
            // Header with question and current emoji
            HStack {
                Text("How are you feeling?")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3)) // Dark gray color
                Spacer()
				if let emoji = currentMood?.emoji {
					Text(emoji)
				}
            }
            
            // Custom Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.93, green: 0.94, blue: 0.96)) // Light gray
                        .frame(height: 20)
                    
                    // Fill track (black part)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.05, green: 0.05, blue: 0.1)) // Very dark color
                        .frame(width: geometry.size.width * CGFloat(sliderValue), height: 20)
                    
                    // Draggable thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle().stroke(Color(red: 0.05, green: 0.05, blue: 0.1), lineWidth: 2)
                        )
                        .offset(x: (geometry.size.width - 28) * CGFloat(sliderValue))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    // Calculate new slider value based on drag location
                                    let newValue = value.location.x / geometry.size.width
                                    // Clamp value between 0.0 and 1.0
                                    sliderValue = min(max(Double(newValue), 0.0), 1.0)
                                }
                        )
                }
            }
			.onChange(of: sliderValue) { _, newValue in
				currentMood = MoodOptions.getOption(by: newValue)
			}

			HStack {
                Text("😢 Not great")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("🤩 Amazing")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct MoodSliderView_Previews: PreviewProvider {
	struct WithBindingPreview: View {
		@State var mood: MoodOptions? = .normal
		var body: some View {
			MoodSliderView(currentMood: $mood)
				.padding()
		}
	}

	static var previews: some View {
		Group {
			WithBindingPreview()
		}
		.previewLayout(.sizeThatFits)
	}
}
