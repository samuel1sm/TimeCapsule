import SwiftUI

extension EntryModel {

	func getBaseColor() -> Color {
		switch entryType {
				case .note: .blue
				case .media: .purple
				case .voiceNote: .red
				case .mood: .yellow
		}
	}

	func getIcon() -> String {
		switch entryType {
			case .note: "doc.text"
			case .media: "photo.on.rectangle"
			case .voiceNote: "mic.fill"
			case .mood: noteModel?.mood?.emoji ?? "😐"
		}
	}

	func getTitle() -> String {
		switch entryType {
		case .note: "Note"
		case .media: "Midia"
		case .voiceNote: "Voice note"
		case .mood: noteModel?.mood?.text ?? "normal"
		}
	}
}
