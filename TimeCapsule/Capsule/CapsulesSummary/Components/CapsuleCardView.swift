import SwiftUI
import UIKit

struct CapsuleCardView: View {
    let item: CapsuleItem
    var showsDelete: Bool = false
    var onDelete: (() -> Void)? = nil

    var body: some View {
        let firstImageURL = item.firstImageURl

        ZStack(alignment: .bottomLeading) {
            Group {
                if let firstImageURL {
                    LocalFileImage(url: firstImageURL)
                        .frame(height: 220)
                        .clipped()
                } else {
                    ZStack {
                        Color(.systemGray6)
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .padding(24)
                    }
                }
            }
            .frame(height: 220)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [Color.black.opacity(0.6), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(alignment: .topTrailing) {
                if showsDelete {
                    Button {
                        onDelete?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                            .padding(6)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete capsule")
                    .transition(.scale.combined(with: .opacity))
                    .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.title3).bold()
                    .foregroundStyle(.white)
                    .shadow(radius: 3)

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundStyle(.white.opacity(0.9))
					Text("Opens in \(item.timeRemainingString())")
                        .foregroundStyle(.white.opacity(0.9))
                        .font(.subheadline)
                }
            }
            .padding(20)
        }
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }
}

#Preview {
    Text("Preview")
}
