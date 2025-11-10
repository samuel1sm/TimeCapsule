import SwiftUI

enum CapsuleRoute: Hashable {
	case createCapsule
}

struct CapsulesSummary: View {
	// Sample data for preview / development
	private let capsules: [CapsuleItem] = [
//		.init(title: "Summer 2025 Memories",
//			  openDate: Calendar.current.date(byAdding: .day, value: 728, to: .now)!,
//			  imageName: "capsule_summer"),
//		.init(title: "Mountain Adventure",
//			  openDate: Calendar.current.date(byAdding: .day, value: 230, to: .now)!,
//			  imageName: "capsule_mountain"),
		.init(title: "City Nights",
			  openDate: Calendar.current.date(byAdding: .day, value: 65, to: .now)!,
			  imageName: "capsule_city")
	]
	
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
								CapsuleCard(item: capsule)
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
