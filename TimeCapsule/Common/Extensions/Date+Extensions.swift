import Foundation

extension Date {
	func adding(_ component: Calendar.Component, _ value: Int,
				calendar: Calendar = .current) -> Date {
		calendar.date(byAdding: component, value: value, to: self) ?? self
	}
}
