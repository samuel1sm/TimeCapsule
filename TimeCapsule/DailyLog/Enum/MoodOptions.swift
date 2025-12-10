enum MoodOptions {

	case crying
	case sad
	case normal
	case happy
	case overjoy

	var emoji: String {
		switch self {
		case .crying: "😢"
		case .sad: "😕"
		case .normal: "😐"
		case .happy: "😄"
		case .overjoy: "🤩"
		}
	}
}

extension MoodOptions {

	static func getOption(by persentage: Double)  -> MoodOptions {
		switch persentage {
			case 0..<0.2: .crying
			case 0.2..<0.4: .sad
			case 0.4..<0.6: .normal
			case 0.6..<0.8: .happy
			default: .overjoy
		}
	}
}
