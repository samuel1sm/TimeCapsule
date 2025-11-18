import SwiftUI
import SwiftData

enum CapsuleRoute: Hashable {
	case createCapsule
}

struct CapsulesSummary: View {

	@Query var capsulesData: [CapsuleModel]
	@State private var path = NavigationPath()
	@Environment(\.modelContext) private var modelContext

	@State private var isDeleteMode = false

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
								VStack(spacing: 20) {
									Image(systemName: "archivebox")
										.font(.system(size: 52, weight: .regular))
										.foregroundStyle(.secondary)

									VStack(spacing: 6) {
										Text("No Capsules Yet")
											.font(.title3).bold()
										Text("Start by creating your first time capsule.")
											.font(.subheadline)
											.foregroundStyle(.secondary)
									}
									Button {
										path.append(CapsuleRoute.createCapsule)
									} label: {
										HStack(spacing: 8) {
											Image(systemName: "plus.circle.fill")
											Text("Create New Capsule")
												.fontWeight(.semibold)
										}
										.frame(height: 50)
										.frame(maxWidth: .infinity)
									}
									.buttonStyle(.sealCapsuleGradient)
									.tint(.pink)
									.padding(.top, 8)
								}
								.padding()
								.frame(maxWidth: .infinity)
								.background(
									RoundedRectangle(cornerRadius: 16, style: .continuous)
										.fill(Color(.secondarySystemGroupedBackground))
								)
								.padding(.horizontal)
								.padding(.top, 20)
							} else {
								LazyVStack(spacing: 16) {
									ForEach(capsulesData) { capsule in
										CapsuleCardView(
											item: capsule.capsuleItem,
											showsDelete: isDeleteMode
										) {
											removeCapsule(id: capsule.capsuleID)
										}
										.onLongPressGesture(minimumDuration: 0.5) {
											withAnimation(.spring()) {
												isDeleteMode = true
											}
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
					Button(action: { path.append(CapsuleRoute.createCapsule) }) {
						Image(systemName: "plus")
							.font(.system(size: 28))
							.foregroundStyle(.white)
							.padding(16)
							.background(
								LinearGradient(
									colors: [Color.pink, Color.purple],
									startPoint: .topLeading,
									endPoint: .bottomTrailing
								)
							)
							.clipShape(Circle())
							.shadow(radius: 12, y: 6)
					}
					.padding(.trailing, 20)
					.padding(.bottom, 28)
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
