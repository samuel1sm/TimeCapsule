import SwiftUI
import Combine

struct DailyLogView: View {
	@State private var closesInString: String = "--"
	@State private var feelingText = ""
	@FocusState private var isComposerFocused: Bool
	@State private var entries: [EntryModel] = []
	private let horizontalSpacing = 16

	var body: some View {
		let _ = Self._printChanges()
			VStack(alignment: .leading, spacing: 0) {
				DailyLogHeaderView()
				.padding(.horizontal)
				.padding(.top)
				.padding(.bottom, 24)
				Divider()

				if entries.isEmpty {
					VStack(spacing: 24) {
							CaptureMomentView()
						.padding(.horizontal)
						Divider()
					}
					.padding(.top, 24)
					.background(Color(.systemGroupedBackground))
				}

				List(entries) { item in
					LogEntryCardView(entry: item).listRowSeparator(.hidden)
				}.listStyle(.plain)

				InputContainerView(
					thoughtsText: $feelingText,
					isFocused: $isComposerFocused,
					sendNote: newEntryWasClicked
				).background(.ultraThinMaterial)
			}
			.frame(maxWidth: .infinity)
		.simultaneousGesture(TapGesture().onEnded { isComposerFocused = false })
	}

	private func newEntryWasClicked(_ entrie : EntryModel) {
		entries.append(entrie)
	}
}

#Preview {
	DailyLogView()
}
