import SwiftUI
import Combine

struct DailyLogHeaderView: View {
	@State private var now = Date()
	@State var closesTimeText: String = ""
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
	
	var body: some View {
		VStack(alignment: .trailing, spacing: 8) {
			HStack(alignment: .bottom, spacing: 0) {
				Text("Today's Log")
					.font(.title3.weight(.semibold))
				Spacer()
				Text(todayString)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			HStack(spacing: 8) {
				Image(systemName: "clock")
					.font(.subheadline.weight(.semibold))

				Text("Closes in \(closesTimeText)")
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
		.onReceive(timer) { date in
			now = date
			closesTimeText = computeClosesInString(from: date)
		}
		.onAppear {
			closesTimeText = computeClosesInString(from: now)
		}
	}

	private func computeClosesInString(from date: Date) -> String {
		let calendar = Calendar.current
		guard let midnight = calendar.nextDate(
			after: date,
			matching: DateComponents(hour: 0, minute: 0, second: 0),
			matchingPolicy: .nextTimePreservingSmallerComponents
		) else { return "--" }

		let interval = max(0, midnight.timeIntervalSince(date))
		return Self.timeFormatter.string(from: interval) ?? "--"
	}
}

#Preview {
	DailyLogHeaderView()
	.padding()
}
