import SwiftUI

struct InputComposerView: View {
    @Binding var text: String

    @State private var isExpanded = false
    @State private var includeLocation = false
    @State private var moodValue: Double = 0.5        // 0 = bad, 1 = amazing

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Top actions
            HStack(spacing: 12) {
                TopPillButton(
                    icon: "mic.fill",
                    title: "Voice",
                    isPrimary: false
                ) {
                    // trigger recording
                }

                TopPillButton(
                    icon: "camera.fill",
                    title: "Photo",
                    isPrimary: false
                ) {
                    // trigger camera
                }

                TopPillButton(
                    icon: "plus",
                    title: isExpanded ? "Less" : "More",
                    isPrimary: true,
                    isActive: isExpanded
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        isExpanded.toggle()
                    }
                }
            }

            // Text input
            TextEditor(text: $text)
                .padding(8)
                .frame(minHeight: 80, maxHeight: 160, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

            // Extra content when expanded
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {

                    // Add media section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Media")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            SecondaryPillButton(icon: "photo", title: "Photo") { }
                            SecondaryPillButton(icon: "video.fill", title: "Video") { }
                            SecondaryPillButton(icon: "photo.on.rectangle", title: "Gallery") { }
                        }
                    }

                    // Location row
                    HStack {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "location")
                                        .foregroundStyle(.secondary)
                                )

                            Text("Location")
                                .font(.body)
                        }

                        Spacer()

                        Toggle("", isOn: $includeLocation)
                            .labelsHidden()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.02), radius: 4, y: 2)
                    )

                    // Mood slider
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 16) {
                            Text(moodEmoji)
                                .font(.system(size: 36))

                            // slider + track
                            ZStack {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.black, Color(.systemGray5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 14)

                                Slider(value: $moodValue)
                                    .tint(.clear) // so we only see our custom track
                                    .padding(.horizontal, -2)
                            }

                            HStack {
                                Text("Not great")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text("Amazing")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                        )
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var moodEmoji: String {
        switch moodValue {
        case ..<0.25:  return "☹️"
        case ..<0.5:   return "😕"
        case ..<0.75:  return "🙂"
        default:       return "😄"
        }
    }
}

// MARK: - Subviews

struct TopPillButton: View {
    let icon: String
    let title: String
    var isPrimary: Bool
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isPrimary {
                        if isActive {
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color(.systemGray6)
                        }
                    } else {
                        Color(.systemGray6)
                    }
                }
            )
            .foregroundStyle(isPrimary && isActive ? Color.white : Color.primary.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryPillButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .font(.footnote)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct InputComposerView_Previews: PreviewProvider {
    static var previews: some View {
        InputComposerView(text: .constant("teste"))
            .previewLayout(.sizeThatFits)
    }
}