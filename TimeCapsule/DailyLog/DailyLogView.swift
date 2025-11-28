import SwiftUI
import Combine

struct DailyLogView: View {
	@State private var now = Date()
	private let horizontalSpacing = 16

	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .full
		formatter.timeStyle = .none
		return formatter
	}()

	private static let timeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = .positional
		formatter.zeroFormattingBehavior = [.pad]
		return formatter
	}()

	private var todayString: String {
		Self.dateFormatter.string(from: now)
	}

	private var closesInString: String {
		let calendar = Calendar.current

		guard let midnight = calendar.nextDate(
			after: now,
			matching: DateComponents(hour: 0, minute: 0, second: 0),
			matchingPolicy: .nextTimePreservingSmallerComponents
		) else { return "--" }

		let interval = max(0, midnight.timeIntervalSince(now))
		return Self.timeFormatter.string(from: interval) ?? "--"
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				// Header
				VStack(alignment: .leading, spacing: 4) {
					Text("Today's Log")
						.font(.title3.weight(.semibold))

					Text(todayString)
						.font(.subheadline)
						.foregroundStyle(.secondary)

					// Countdown pill
					HStack(spacing: 8) {
						Image(systemName: "clock")
							.font(.subheadline.weight(.semibold))

						Text("Closes in \(closesInString)")
							.font(.subheadline.weight(.semibold))
					}
					.padding(.horizontal, 14)
					.padding(.vertical, 8)
					.background(
						Capsule()
							.fill(Color.orange.opacity(0.1))
					)
					.foregroundStyle(Color.orange)
				}
				.padding(.horizontal)
				.padding(.top)

				VStack(spacing: 24) {
					Divider()

					VStack {
						CaptureMomentView()
					}.padding(.horizontal)
				}
				.background(Color(.systemGroupedBackground))
				.onReceive(
					Timer.publish(every: 1, on: .main, in: .common).autoconnect()
				) { date in
					now = date
				}
			}
			.frame(maxWidth: .infinity)
		}.frame(maxWidth: .infinity)
	}
}

#Preview {
	DailyLogView()
}
