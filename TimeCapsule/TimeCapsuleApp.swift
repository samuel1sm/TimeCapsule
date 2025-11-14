import SwiftUI
import SwiftData

@main
struct TimeCapsuleApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
		}.modelContainer(for: [CapsuleModel.self])
    }
}
