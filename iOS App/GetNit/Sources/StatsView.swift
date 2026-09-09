import SwiftUI

struct StatsView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Environment(\.dismiss) var dismiss
    @State private var deviceTotal: Int64 = 0
    @State private var deviceAvailable: Int64 = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = manager.libraryStats {
                        // Device storage
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "internaldrive.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.orange)
                                    .frame(width: 50)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total iPhone Storage")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(ByteCountFormatter.string(fromByteCount: deviceTotal, countStyle: .file))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }

                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green)
                                    .frame(width: 50)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Available Space")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(ByteCountFormatter.string(fromByteCount: deviceAvailable, countStyle: .file))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Photos storage
                        StatCard(
                            icon: "photo.stack.fill",
                            color: .blue,
                            title: "Photos Storage",
                            value: ByteCountFormatter.string(fromByteCount: stats.estimatedStorage, countStyle: .file)
                        )

                        // Total photos
                        StatCard(
                            icon: "photo.on.rectangle.fill",
                            color: .blue,
                            title: "Total Photos",
                            value: "\(stats.totalPhotos)"
                        )

                        // Videos
                        StatCard(
                            icon: "video.fill",
                            color: .green,
                            title: "Total Videos",
                            value: "\(stats.totalVideos)"
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
            .onAppear { loadDeviceStorage() }
        }
    }

    private func loadDeviceStorage() {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            deviceTotal = Int64(values.volumeTotalCapacity ?? 0)
            deviceAvailable = Int64(values.volumeAvailableCapacity ?? 0)
        } catch {}
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
