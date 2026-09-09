import SwiftUI

struct StatsView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = manager.libraryStats {
                        // Total photos
                        StatCard(
                            icon: "photo.stack.fill",
                            color: .blue,
                            title: "Total Photos",
                            value: "\(stats.totalPhotos)"
                        )

                        // Storage used
                        StatCard(
                            icon: "internaldrive.fill",
                            color: .orange,
                            title: "Estimated Storage",
                            value: ByteCountFormatter.string(fromByteCount: stats.estimatedStorage, countStyle: .file)
                        )

                        // Screenshots
                        StatCard(
                            icon: "camera.viewfinder",
                            color: .purple,
                            title: "Screenshots",
                            value: "\(stats.totalScreenshots)"
                        )

                        // Duplicates
                        StatCard(
                            icon: "doc.on.doc.fill",
                            color: .red,
                            title: "Duplicate Groups",
                            value: "\(manager.duplicateGroups.count) (\(stats.totalDuplicates) photos)"
                        )

                        // Marked for deletion
                        if !manager.markedForDeletion.isEmpty {
                            StatCard(
                                icon: "trash.fill",
                                color: .pink,
                                title: "Marked for Deletion",
                                value: "\(manager.markedForDeletion.count)"
                            )
                        }
                    } else {
                        ProgressView("Calculating library stats...")
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Library Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct StatCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}
