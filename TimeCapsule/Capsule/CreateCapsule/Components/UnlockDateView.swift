import SwiftUI

struct UnlockDateView: View {
	@Binding var unlockDate: Date?
	@State private var showPicker = false
	@State private var tempDate = Date()

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text("Unlock Date & Time")
					.font(.headline)
				Spacer()
				if unlockDate != nil {
					Button("Clear") { unlockDate = nil }
						.font(.subheadline)
				}
			}

			if unlockDate == nil {
				// Placeholder that opens the picker when tapped
				Button {
					tempDate = Date()
					showPicker = true
				} label: {
					HStack(spacing: 12) {
						Image(systemName: "calendar.badge.exclamationmark")
						VStack(alignment: .leading, spacing: 2) {
							Text("No date selected")
								.font(.subheadline)
								.foregroundStyle(.secondary)
							Text("Tap to choose when this capsule unlocks")
								.font(.footnote)
								.foregroundStyle(.secondary)
						}
						Spacer()
						Image(systemName: "chevron.right")
							.font(.footnote)
							.foregroundStyle(.secondary)
					}
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color(.systemGray6))
					.cornerRadius(10)
				}
				.buttonStyle(.plain)
			} else {
				// When there is a selected date, show compact inline controls
				HStack {
					DatePicker(
						"",
						selection: bindingToOptional,
						displayedComponents: .date
					)
					.datePickerStyle(.compact)
					.labelsHidden()
					.frame(maxWidth: .infinity)

					Divider()

					DatePicker(
						"",
						selection: bindingToOptional,
						displayedComponents: .hourAndMinute
					)
					.datePickerStyle(.compact)
					.labelsHidden()
					.frame(maxWidth: .infinity)
				}
				.padding()
				.background(Color(.systemGray6))
				.cornerRadius(10)
			}
		}
		.sheet(isPresented: $showPicker) {
			NavigationStack {
				VStack(spacing: 16) {
					DatePicker(
						"Date",
						selection: $tempDate,
						in: Date.now.adding(.day, 1)...,
						displayedComponents: .date
					).datePickerStyle(.graphical)
				}
				.padding()
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Select unlock date")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel") { showPicker = false }
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							unlockDate = tempDate
							showPicker = false
						}
					}
				}
			}
			.presentationDetents([.medium])
		}
	}

	// Bridges the optional binding into a non-optional one for DatePicker
	private var bindingToOptional: Binding<Date> {
		Binding<Date>(
			get: { unlockDate ?? tempDate },
			set: { newValue in
				tempDate = newValue
				unlockDate = newValue
			}
		)
	}
}

#Preview {
	// Start with nil to see the placeholder behavior
	UnlockDateView(unlockDate: .constant(nil))
}
