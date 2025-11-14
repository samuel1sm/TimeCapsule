import SwiftUI
import SwiftData

enum CapsuleRoute: Hashable {
	case createCapsule
}

struct CapsulesSummary: View {

	@Query var capsules: [CapsuleModel]
	@State private var path = NavigationPath()
	
	var body: some View {
		NavigationStack(path: $path) {
			ZStack(alignment: .bottomTrailing) {
				ScrollView {
					VStack(alignment: .leading, spacing: 16) {
						// Header
						VStack(alignment: .leading, spacing: 6) {
							Text("My Capsules")
								.font(.largeTitle).bold()
							Text("Your treasured memories")
								.foregroundStyle(.secondary)
						}
						.padding(.horizontal)
						.padding(.top)
						
						VStack(spacing: 16) {
							ForEach(capsules) { capsule in
								CapsuleCardView(item: capsule.toCapsuleItem())
							}
						}
						.padding(.horizontal)
						.padding(.bottom, 10)
					}
				}
				
				// Floating Action Button
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
			.background(Color(.systemGroupedBackground))
			.navigationDestination(for: CapsuleRoute.self) { route in
				switch route {
				case .createCapsule:
					CreateCapsule()
				}
			}
		}
	}
}

// MARK: - Model

#Preview {
	CapsulesSummary()
}
