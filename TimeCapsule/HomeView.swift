import SwiftUI

struct HomeView: View {
	var body: some View {
		TabView {
			// Home tab
			Text("Home")
				.tabItem {
					Label("Home", systemImage: "house")
				}

			CapsulesSummary()
				.tabItem {
					Label("Capsule", systemImage: "capsule.lefthalf.filled")
				}

			// Calendar tab
			Text("Calendar")
				.tabItem {
					Label("Calendar", systemImage: "calendar")
				}

			// Settings tab
			Text("Settings")
				.tabItem {
					Label("Settings", systemImage: "gearshape")
				}
		}
	}
}

#Preview {
	HomeView()
}
