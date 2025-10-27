import Foundation

struct CapsuleItem: Identifiable {

	let id = UUID()
	let title: String
	let openDate: Date
	let imageName: String

	func timeRemainingString(from reference: Date = .now) -> String {
		let cal = Calendar.current
		let comps = cal.dateComponents([.year, .day, .hour], from: reference, to: openDate)
		var parts: [String] = []
		if let y = comps.year, y > 0 { parts.append("\(y) yr") }
		if let d = comps.day, d > 0 { parts.append("\(d) d") }
		if let h = comps.hour, h > 0 { parts.append("\(h) h") }
		return parts.joined(separator: ", ")
	}
}
