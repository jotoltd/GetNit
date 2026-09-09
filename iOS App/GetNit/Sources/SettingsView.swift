import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("rememberReviewed") private var rememberReviewed = true

    var body: some View {
        NavigationView {
            Form {
                Section("Haptics") {
                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                }

                Section("Review History") {
                    Toggle("Remember Reviewed Photos", isOn: $rememberReviewed)
                        .onChange(of: rememberReviewed) { _, value in
                            manager.setRememberReviewed(value)
                        }
                    Button("Clear Review History", role: .destructive) {
                        manager.clearReviewHistory()
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("GetNit Photo Cleaner")
                        Spacer()
                        Text("© 2026 Joshua Geddes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
