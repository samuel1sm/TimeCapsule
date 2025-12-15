import SwiftUI
import Combine

struct DailyLogView: View {
	@State private var now = Date()
	@State private var closesInString: String = "--"
	@State private var feelingText = ""
	@FocusState private var isComposerFocused: Bool
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

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				DailyLogHeaderView(
					todayString: todayString,
					closesTimeText: $closesInString
				)
				.padding(.horizontal)
				.padding(.top)

				VStack(spacing: 24) {
					Divider()

					VStack {
						CaptureMomentView()
					}
					.padding(.horizontal)

					Divider()
				}
				.background(Color(.systemGroupedBackground))
			}
			.frame(maxWidth: .infinity)
		}
		.simultaneousGesture(TapGesture().onEnded { isComposerFocused = false })
		.safeAreaInset(edge: .bottom) {
			InputContainerView(
				thoughtsText: $feelingText,
				isFocused: $isComposerFocused,
				action: newEntryWasClicked
			).background(.ultraThinMaterial)
		}
		.onReceive(
			Timer.publish(every: 1, on: .main, in: .common).autoconnect()
		) { date in
			now = date
			closesInString = computeClosesInString(from: date)
		}
		.onAppear {
			closesInString = computeClosesInString(from: now)
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

	private func newEntryWasClicked(_ option : LogEntryOptions) {

	}
}

#Preview {
	DailyLogView()
}
