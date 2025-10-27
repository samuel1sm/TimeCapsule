//
//  CreateCapsule.swift
//  TimeCapsule
//
//  Created by Samuel Martins on 27/10/25.
//

import SwiftUI

struct CreateCapsule: View {
	@State private var title: String = ""
	@State private var message: String = ""
	@State private var unlockDate = Date()
	@State private var isPrivate = true
	@State private var showMediaPicker = false
	@State private var selectedMedia: [UIImage] = []

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				VStack(alignment: .leading, spacing: 8) {
					Text("Capsule Title")
						.font(.headline)
					TextField(
						"",
						text: $title,
						prompt: Text("e.g., Dear Future Me").foregroundStyle(.gray)
					)
						.padding()
						.background(Color(.systemGray6))
						.cornerRadius(10)
						.overlay(
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color(.systemGray4))
						)
				}

				// Your Message
				VStack(alignment: .leading, spacing: 8) {
					Text("Your Message").font(.headline)
					TextEditor(text: $message)
						.frame(height: 120)
						.scrollContentBackground(.hidden)
						.padding(8)
						.background(Color(.systemGray6))
						.cornerRadius(10)
						.overlay(
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color(.systemGray4))
						)
						.overlay(
							Group {
								if message.isEmpty {
									Text("Write a note to your future self or describe this moment...")
										.foregroundColor(.gray)
										.padding(16)
										.allowsHitTesting(false)
								}
							},
							alignment: .topLeading
						)
				}

				// Photos & Videos
				VStack(alignment: .leading, spacing: 8) {
					Text("Photos & Videos")
						.font(.headline)
					Button {
						showMediaPicker.toggle()
					} label: {
						VStack(spacing: 12) {
							Image(systemName: "arrow.up.circle")
								.font(.system(size: 36))
								.foregroundColor(Color.purple)
							Text("Add photos or videos")
								.font(.subheadline)
								.foregroundColor(.primary)
							Text("Tap to upload media")
								.font(.footnote)
								.foregroundColor(.gray)
							HStack(spacing: 16) {
								Image(systemName: "photo.on.rectangle")
								Image(systemName: "video")
							}
							.foregroundColor(.gray)
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 12)
								.strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
						)
					}
				}

				// Unlock Date
				VStack(alignment: .leading, spacing: 8) {
					Text("Unlock Date & Time")
						.font(.headline)
					HStack {
						VStack(alignment: .leading, spacing: 4) {
							Text("Date").font(.subheadline)
							DatePicker(
								"Choose when you want to open this capsule",
								selection: $unlockDate,
								displayedComponents: .date
							)
							.frame(maxWidth: .infinity)
							.labelsHidden()
							.padding()
							.background(Color(.systemGray6))
							.cornerRadius(10)
						}
						VStack(alignment: .leading, spacing: 4) {
							Text("Hour").font(.subheadline)
							DatePicker(
								"Choose when you want to open this capsule",
								selection: $unlockDate,
								displayedComponents: .hourAndMinute
							)
							.frame(maxWidth: .infinity)
							.labelsHidden()
							.padding()
							.background(Color(.systemGray6))
							.cornerRadius(10)
						}
					}
				}

				// Privacy Settings
				VStack(alignment: .leading, spacing: 8) {
					Text("Privacy Settings")
						.font(.headline)
					HStack(spacing: 12) {
						Button(action: { isPrivate = true }) {
							VStack {
								Image(systemName: "lock.fill")
								Text("Private")
							}
							.frame(maxWidth: .infinity)
							.padding()
							.background(isPrivate ? Color.purple.opacity(0.1) : Color(.systemGray6))
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(isPrivate ? Color.purple : Color.clear, lineWidth: 2)
							)
							.cornerRadius(12)
						}
						Button(action: { isPrivate = false }) {
							VStack {
								Image(systemName: "person.2")
								Text("Shareable")
							}
							.frame(maxWidth: .infinity)
							.padding()
							.background(!isPrivate ? Color.purple.opacity(0.1) : Color(.systemGray6))
							.overlay(
								RoundedRectangle(cornerRadius: 12)
									.stroke(!isPrivate ? Color.purple : Color.clear, lineWidth: 2)
							)
							.cornerRadius(12)
						}
					}
				}
			}
			.padding()
		}
		.navigationTitle("Create Capsule")
		.sheet(isPresented: $showMediaPicker) {
			Text("Media picker placeholder")
		}
	}
}

#Preview {
	CreateCapsule()
}
