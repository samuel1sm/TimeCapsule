import SwiftUI
import SwiftData

enum CapsuleRoute: Hashable {
	case createCapsule
}

struct CapsulesSummary: View {

	@Query(sort: \CapsuleModel.openDate, order: .forward) var capsulesData: [CapsuleModel]
	@State private var path: NavigationPath = NavigationPath()
	@Environment(\.modelContext) private var modelContext

	@State private var viewModel = CapsulesSummaryViewModel()

	var body: some View {
		NavigationStack(path: $path) {
			ZStack(alignment: .bottomTrailing) {
				ScrollView {
					VStack(alignment: .leading, spacing: 16) {
						CapsuleSummaryHeaderView()

						if capsulesData.isEmpty {
							EmptyCapsulesView {
								let route: CapsuleRoute = .createCapsule
								path.append(route)
							}
						} else {
							capsulesList(capsulesData)
								.padding(.horizontal)
								.padding(.bottom, 10)
								.animation(.spring(), value: viewModel.isDeleteMode)
						}
					}
				}
				.frame(maxWidth: .infinity)

				if !capsulesData.isEmpty {
					FloatingButtonView {
						let route: CapsuleRoute = .createCapsule
						path.append(route)
					}.padding(.trailing, 12)
					.padding(.bottom, 12)
				}
			}
			.onTapGesture {
				if viewModel.isDeleteMode {
					withAnimation(.spring()) {
						viewModel.isDeleteMode = false
					}
				}
			}
			.navigationDestination(for: CapsuleRoute.self) { route in
				switch route {
				case .createCapsule:
					CreateCapsule()
				}
			}
			.frame(maxWidth: .infinity)
			.background(Color(.systemGroupedBackground))
		}
	}

	@ViewBuilder
	private func capsulesList(_ capsules: [CapsuleModel]) -> some View {
		LazyVStack(spacing: 16) {
			ForEach(capsules) { capsule in
				CapsuleCardView(
					item: capsule.toCapsuleItem(),
					showsDelete: viewModel.isDeleteMode,
					onDelete: { viewModel.confirmDeletion(of: capsule) }
				)
				.confirmationDialog(
					"Delete Capsule?",
					isPresented: $viewModel.showDeleteDialog,
					titleVisibility: .visible,
					presenting: viewModel.capsuleToDelete
				) { capsule in
					Button("Delete", role: .destructive) {
						viewModel.performDelete(using: modelContext, from: capsulesData)
						viewModel.capsuleToDelete = nil
						withAnimation(.spring()) { viewModel.isDeleteMode = false }
					}
					Button("Cancel", role: .cancel) {
						viewModel.capsuleToDelete = nil
					}
				} message: { capsule in
					Text("Are you sure you want to delete “\(capsule.title)”? This action cannot be undone.")
				}
				.onLongPressGesture(minimumDuration: 0.5) {
					withAnimation(.spring()) {
						viewModel.isDeleteMode = true
					}
				}
			}
		}
	}
}

// MARK: - Model

#Preview {
	CapsulesSummary()
}
