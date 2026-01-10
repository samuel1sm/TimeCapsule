import SwiftUI
import Combine

struct DailyLogHeaderView: View {
	@State private var now = Date()
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@Binding var interval: Double
	@State var closesTimeText: String = ""

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
			computeClosesInterval(from: date)
		}
		.onAppear {
			computeClosesInterval(from: now)
		}
	}

	private func computeClosesInterval(from date: Date) {
		let calendar = Calendar.current
		guard let midnight = calendar.nextDate(
			after: date,
			matching: DateComponents(hour: 0, minute: 0, second: 0),
			matchingPolicy: .nextTimePreservingSmallerComponents
		) else { return }

		interval = max(0, midnight.timeIntervalSince(date))
		closesTimeText = Self.timeFormatter.string(from: interval) ?? "--"
	}
}

#Preview {
	DailyLogHeaderView(interval: .constant(60))
	.padding()
}
