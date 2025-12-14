import SwiftUI

struct InputOptionView: View {
    let option: InputOption
    var action: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            RoundButtonView(
                systemImageName: option.systemImageName,
                colors: option.gradientColors,
                iconScale: 0.4,
                action: action
            )
            
            Text(option.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary) // Ensure text is visible
        }
        .frame(maxWidth: .infinity)
    }
}

struct InputOptionView_Previews: PreviewProvider {
	static var previews: some View {
		HStack(spacing: 20) {
			InputOptionView(option: .camera, action: {})
			InputOptionView(option: .gallery, action: {})
		}
		.padding()
		.previewLayout(.sizeThatFits)
	}
}
