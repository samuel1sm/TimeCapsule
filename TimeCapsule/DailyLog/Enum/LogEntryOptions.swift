import SwiftUI

enum LogEntryOptions {

    case note(text: String)
    case photos(count: Int, thumbnails: [Image])
    case voiceNote(recordings: Int)
    case mood(description: String, emoji: String)
}

// MARK: - Styling helpers

extension LogEntryOptions {
    var color: Color {
        switch self {
        case .note:        return .blue
        case .photos:      return .purple
        case .voiceNote:   return .red
        case .mood:        return .yellow
        }
    }

    var iconName: String {
        switch self {
        case .note:        return "doc.text"
        case .photos:      return "photo.on.rectangle"
        case .voiceNote:   return "mic.fill"
        case .mood:        return "face.smiling"
        }
    }

    var title: String {
        switch self {
        case .note:
            return "Note"
        case let .photos(count, _):
            return "\(count) Photos"
        case .voiceNote:
            return "Voice Note"
        case .mood:
            return "Mood"
        }
    }
}
