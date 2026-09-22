import SwiftUI
import Photos
import StoreKit

struct HomeView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Binding var hasStartedSwiping: Bool
    @State private var showFilters = false
    @State private var showStats = false
    @State private var showSettings = false
    @State private var deviceStorage: DeviceStorage?
    @State private var requestReview = false
    @State private var showDeleteAllConfirm = false
    @Environment(\.requestReview) private var requestReviewAction

    struct DeviceStorage {
        let total: Int64
        let available: Int64
        let used: Int64
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with logo centered
            ZStack {
                // Settings on left
                HStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.circle")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }

                // Logo centered
                HStack(spacing: 10) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                    Text("GetNit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                // Heart/rate button on right
                HStack {
                    Spacer()
                    Button(action: {
                        requestReview = true
                    }) {
                        Image(systemName: "heart.circle")
                            .font(.system(size: 26))
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)

            // Stats section
            if let stats = manager.libraryStats, let storage = deviceStorage {
                VStack(spacing: 16) {
                    // Storage card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "internaldrive.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("iPhone Storage")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(ByteCountFormatter.string(fromByteCount: storage.total, countStyle: .file))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }

                        // Storage bar
                        VStack(spacing: 8) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 20)

                                    let usedFraction = CGFloat(storage.used) / CGFloat(max(storage.total, 1))
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange)
                                        .frame(width: geo.size.width * usedFraction, height: 20)

                                    if stats.estimatedStorage > 0 {
                                        let photoFraction = CGFloat(stats.estimatedStorage) / CGFloat(max(storage.total, 1))
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue)
                                            .frame(width: geo.size.width * photoFraction, height: 20)
                                    }
                                }
                            }
                            .frame(height: 20)

                            // Used vs Free big numbers
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("USED")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(ByteCountFormatter.string(fromByteCount: storage.used, countStyle: .file))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                }

                                Spacer()

                                VStack(alignment: .center, spacing: 2) {
                                    Text("PHOTOS")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(ByteCountFormatter.string(fromByteCount: stats.estimatedStorage, countStyle: .file))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("FREE")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(ByteCountFormatter.string(fromByteCount: storage.available, countStyle: .file))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)

                    // Quick stats grid - 2 per row
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        QuickStatCard(icon: "photo.stack.fill", color: .blue, label: "Photos", value: "\(stats.totalPhotos)")
                            .onTapGesture {
                                manager.filters.screenshotsOnly = false
                                manager.filters.videosOnly = false
                                manager.filters.duplicatesOnly = false
                                manager.loadAssets()
                                hasStartedSwiping = true
                            }

                        QuickStatCard(icon: "video.fill", color: .green, label: "Videos", value: "\(stats.totalVideos)")
                            .onTapGesture {
                                manager.filters.screenshotsOnly = false
                                manager.filters.videosOnly = true
                                manager.filters.duplicatesOnly = false
                                manager.loadAssets()
                                hasStartedSwiping = true
                            }

                        QuickStatCard(icon: "camera.viewfinder", color: .purple, label: "Screenshots", value: "\(stats.totalScreenshots)")
                            .onTapGesture {
                                manager.filters.screenshotsOnly = true
                                manager.filters.videosOnly = false
                                manager.filters.duplicatesOnly = false
                                manager.loadAssets()
                                hasStartedSwiping = true
                            }

                        QuickStatCard(icon: "doc.on.doc.fill", color: .red, label: "Duplicates", value: "\(manager.duplicateGroups.count)")
                            .onTapGesture {
                                manager.filters.screenshotsOnly = false
                                manager.filters.videosOnly = false
                                manager.filters.duplicatesOnly = true
                                manager.loadAssets()
                                hasStartedSwiping = true
                            }
                    }

                    // Marked for deletion
                    if !manager.markedForDeletion.isEmpty {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.pink)
                            Text("\(manager.markedForDeletion.count) photos marked for deletion")
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .background(Color.pink.opacity(0.15))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture { hasStartedSwiping = true }
                    }
                }
                .padding(.horizontal, 24)
            } else {
                ProgressView("Loading library...")
                    .foregroundColor(.white)
                    .padding(.top, 40)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    hasStartedSwiping = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.point.right.fill")
                        Text("Start Swiping")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(16)
                }

                Button(action: { showFilters = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("Filters")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                Button(action: { showStats = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "chart.bar")
                        Text("View Full Stats")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                Button(action: { showDeleteAllConfirm = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "trash.fill")
                        Text("Delete All")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .alert("Delete All?", isPresented: $showDeleteAllConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Mark All for Review", role: .destructive) {
                manager.markAllForDeletion()
                DispatchQueue.main.async { hasStartedSwiping = true }
            }
        } message: {
            Text("This marks every photo and video matching your current filters for deletion. You'll get one more chance to review before anything is permanently removed.")
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear { loadDeviceStorage() }
        .onChange(of: requestReview) { _, newValue in
            if newValue {
                requestReviewAction()
                requestReview = false
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterView(manager: manager)
        }
        .sheet(isPresented: $showStats) {
            StatsView(manager: manager)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(manager: manager)
        }
    }

    private func loadDeviceStorage() {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            let total = Int64(values.volumeTotalCapacity ?? 0)
            let available = Int64(values.volumeAvailableCapacity ?? 0)
            deviceStorage = DeviceStorage(
                total: total,
                available: available,
                used: total - available
            )
        } catch {
            deviceStorage = DeviceStorage(total: 0, available: 0, used: 0)
        }
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(label): \(value)")
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

private struct QuickStatCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
}
