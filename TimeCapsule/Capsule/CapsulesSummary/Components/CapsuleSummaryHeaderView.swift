import SwiftUI

struct CapsuleSummaryHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("My Capsules")
                .font(.largeTitle).bold()
            Text("Your treasured memories")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CapsuleSummaryHeaderView()
        .background(Color(.systemGroupedBackground))
}
