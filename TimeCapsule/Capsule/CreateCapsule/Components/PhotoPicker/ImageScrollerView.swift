import SwiftUI

struct ImageScrollerView: View {

	@Binding var selectedMediaModel: [SelectedMediaModel]
	@Binding var isShowingPhotoPicker: Bool
	let imagesAreLoading: Bool

	@State private var width: CGFloat = 100
	let onItemSelectedToRemove: (Int) -> Void

	var body: some View {
		let spacing: CGFloat = 10
		let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
		let itemWidth = (width - spacing * 3) / 4
		let rows = Int(ceil(Double(selectedMediaModel.count) / 4))
		let visibleRows = min(rows, 4)
		let gridHeight = itemWidth * CGFloat(visibleRows)
		+ spacing * CGFloat(max(visibleRows - 1, 0))

		VStack {
			ScrollView {
				LazyVGrid(columns: columns, spacing: spacing) {
					ForEach(Array(selectedMediaModel.enumerated()), id: \.element.identifier) { (i, model) in
						ZStack(alignment: .topTrailing) {
							LocalVideoPlayerView(model: model)
								.frame(width: itemWidth, height: itemWidth)
								.clipped()
								.cornerRadius(8)
							Button {
								withAnimation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2)) {
									onItemSelectedToRemove(i)
								}
							} label: {
								Image(systemName: "x.circle")
									.tint(.white)
									.padding(.all, 4)
									.background(.black.opacity(0.6))
									.clipShape(.circle)
							}
							.padding(2)
						}
						.transition(.opacity.combined(with: .scale))
					}
				}
				.animation(
					.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2),
					value: selectedMediaModel
				)
			}
			.scrollDisabled(selectedMediaModel.count <= 16)
			.frame(height: gridHeight)
			.overlay {
				GeometryReader { proxy in
					Color.clear.task(id: proxy.size) {
						width = proxy.size.width
					}
				}
			}

			if imagesAreLoading {
				ProgressView()
					.progressViewStyle(.circular)
					.padding(.top, 16)
			} else {
				HStack(alignment: .center, spacing: 16) {
					Image(systemName: "plus")
					Text("Add more").font(.headline)
				}
				.frame(height: 48)
				.frame(maxWidth: .infinity)
				.padding(.horizontal, 16)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(Color(.systemGray4), lineWidth: 1)
				)
				.contentShape(Rectangle())
				.onTapGesture { isShowingPhotoPicker = true }
			}
		}
	}
}
