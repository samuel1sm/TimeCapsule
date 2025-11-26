import SwiftUI
import SwiftData

enum CapsuleRoute: Hashable {
	case createCapsule
}

struct CapsulesSummary: View {

	@Query(sort: \CapsuleModel.openDate, order: .forward) var capsulesData: [CapsuleModel]
	@State private var path: NavigationPath = NavigationPath()
	@Environment(\.modelContext) private var modelContext

	@State private var isDeleteMode = false
	@State private var showDeleteAlert = false
	@State private var capsuleToDelete: CapsuleModel?

	var body: some View {
		NavigationStack(path: $path) {
			ZStack(alignment: .bottomTrailing) {
				ScrollView {
					VStack(alignment: .leading, spacing: 16) {
						VStack(alignment: .leading, spacing: 6) {
							Text("My Capsules")
								.font(.largeTitle).bold()
							Text("Your treasured memories")
								.foregroundStyle(.secondary)
						}
						.padding(.horizontal)
						.padding(.top)

						Group {
							if capsulesData.isEmpty {
								EmptyCapsulesView {
									let route: CapsuleRoute = .createCapsule
									path.append(route)
								}
							} else {
								LazyVStack(spacing: 16) {
									ForEach(capsulesData) { capsule in
										CapsuleCardView(
											item: capsule.toCapsuleItem(),
											showsDelete: isDeleteMode,
											onDelete: { confirmDeletion(of: capsule) }
										)
										.onLongPressGesture(minimumDuration: 0.5) {
											withAnimation(.spring()) {
												isDeleteMode = true
											}
										}
										.confirmationDialog(
											"Delete Capsule?",
											isPresented: $showDeleteAlert,
											titleVisibility: .visible,
											presenting: capsuleToDelete
										) { item in
											Button("Delete", role: .destructive) {
												removeCapsule(id: item.capsuleID)
												capsuleToDelete = nil
												withAnimation(.spring()) { isDeleteMode = false }
											}
											Button("Cancel", role: .cancel) {
												capsuleToDelete = nil
											}
										} message: { item in
											Text("Are you sure you want to delete “\(item.title)”? This action cannot be undone.")
										}
									}
								}
								.padding(.horizontal)
								.padding(.bottom, 10)
								.animation(.spring(), value: isDeleteMode)
							}
						}
					}
				}
				.frame(maxWidth: .infinity)

				if !capsulesData.isEmpty {
					FloatingButtonView {
						let route: CapsuleRoute = .createCapsule
						path.append(route)
					}
				}
			}.onTapGesture {
				if isDeleteMode {
					withAnimation(.spring()) {
						isDeleteMode = false
					}
				}
			}
			.navigationDestination(for: CapsuleRoute.self) { route in
				switch route {
				case .createCapsule:
					CreateCapsule()
				}
			}
			.background(Color(.systemGroupedBackground))
		}
	}

	private func confirmDeletion(of capsule: CapsuleModel) {
		capsuleToDelete = capsule
		showDeleteAlert = true
	}

	private func removeCapsule(id: UUID) {
		guard let model = capsulesData.first(where: { $0.capsuleID == id }) else { return }
		modelContext.delete(model)
		do {
			try modelContext.save()
		} catch {
			print("Failed to delete capsule:", error)
		}
	}
}

// MARK: - Model

#Preview {
	CapsulesSummary()
}
