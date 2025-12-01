import SwiftUI

extension Array where Element == Color {

	static let purpleGradient = [
		Color.purple.opacity(0.9),
		Color.blue.opacity(0.9)
	]

	static let pinkGradient = [Color.pink, Color.purple]
}

