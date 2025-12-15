import SwiftUI

struct LogEntryCardView: View {

	let entry: EntryModel

    var body: some View {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
						.fill(entry.getBaseColor().opacity(0.12))
                        .frame(width: 42, height: 42)

					if entry.entryType == .mood {
						Text(entry.noteModel?.mood?.emoji ?? "")
							.font(.system(size: 18, weight: .semibold))
					} else {
						Image(systemName: entry.getIcon())
							.font(.system(size: 18, weight: .semibold))
							.foregroundStyle(entry.getBaseColor())
					}
                }

                VStack(alignment: .leading, spacing: 4) {
					Text(entry.getTitle())
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
					.fill(entry.getBaseColor())
			}
    }

    @ViewBuilder
    private var entryContent: some View {
		switch entry.entryType {
		case .note, .mood:
			if let model = entry.noteModel {
				Text(model.note).font(.body)
			}

//        case let .photos(_, thumbnails):
//            PhotoGridView(images: thumbnails)

//        case let .voiceNote
//            Text("\(recordings) recording\(recordings > 1 ? "s" : "")")
//                .font(.body)
		default:
			Text("tedst")
        }
    }
}

#Preview {
	VStack {
		LogEntryCardView(entry: .init(entryType: .note, noteModel: .init(note: "test", mood: nil)))
			.frame(minHeight: 100)

		LogEntryCardView(entry: .init(entryType: .mood, noteModel: .init(note: "test", mood: .happy)))
			.frame(minHeight: 100)
	}.padding(.horizontal)
}
