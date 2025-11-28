import SwiftUI

struct LogEntryCardView: View {
	let entry: LogEntryOptions

    var body: some View {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(entry.color.opacity(0.12))
                        .frame(width: 42, height: 42)

                    Image(systemName: entry.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(entry.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    entryContent
                }

                Spacer()
            }
			.padding()
			.roundedBackground()
			.padding(.leading, 4)
			.background {
				RoundedRectangle(cornerRadius: 20, style: .continuous)
					.fill(entry.color)
			}
    }

    @ViewBuilder
    private var entryContent: some View {
        switch entry {
        case let .note(text):
            Text(text)
                .font(.body)

//        case let .photos(_, thumbnails):
//            PhotoGridView(images: thumbnails)

        case let .voiceNote(recordings):
            Text("\(recordings) recording\(recordings > 1 ? "s" : "")")
                .font(.body)

        case let .mood(description, _):
            Text(description)
                .font(.body)
		default:
			Text("tedst")
        }
    }
}

#Preview {
	LogEntryCardView(entry: .note(text: "teste"))
		.frame(minHeight: 100)
		.padding(.horizontal)
}
