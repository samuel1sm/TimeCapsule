import SwiftUI

enum LogEntryOptions {

	case note(text: String, mood: MoodOptions?)
    case photos(count: Int, thumbnails: [Image])
    case voiceNote(recordings: Int)
}

// MARK: - Styling helpers

extension LogEntryOptions {
    var color: Color {
        switch self {
		case .note(_, let mood):
			return mood == nil ? .blue : .yellow
        case .photos:      return .purple
        case .voiceNote:   return .red
        }
    }

    var iconName: String {
        switch self {
		case .note(_, let mood):
			return mood == nil ? "doc.text" : "face.smiling"
        case .photos:      return "photo.on.rectangle"
        case .voiceNote:   return "mic.fill"
        }
    }

    var title: String {
        switch self {
		case .note(_, let mood):
			return mood == nil ? "Note" : "Mood"
        case let .photos(count, _):
            return "\(count) Photos"
        case .voiceNote:
            return "Voice Note"
        }
    }
}
