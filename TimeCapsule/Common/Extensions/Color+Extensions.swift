import SwiftUI

extension Array where Element == Color {

	static let pinkGradient = [Color.pink, Color.purple]

	static let purpleGradient = [
		Color(red: 0.75, green: 0.20, blue: 0.90), // Violet
		Color(red: 0.95, green: 0.30, blue: 0.70)  // Hot Pink
	]

	// 2. Gallery Icon (Bright Blue to Cyan)
	static let brightBlue = [
		Color(red: 0.10, green: 0.50, blue: 1.00), // Royal Blue
		Color(red: 0.00, green: 0.75, blue: 1.00)  // Sky Blue
	]

	// 3. Video Icon (Red to Orange)
	static let redOrange = [
		Color(red: 1.00, green: 0.30, blue: 0.30), // Bright Red
		Color(red: 1.00, green: 0.55, blue: 0.20)  // Orange
	]

	// 4. Location Icon (Mint to Teal)
	static let mintGreen = [
		Color(red: 0.35, green: 0.90, blue: 0.60), // Mint Green
		Color(red: 0.25, green: 0.85, blue: 0.75)  // Teal Green
	]

	static let brightYellow = [
		Color(red: 1.00, green: 0.90, blue: 0.30), // Sunshine Yellow
		Color(red: 1.00, green: 0.70, blue: 0.10)  // Deep Gold
	]
}
