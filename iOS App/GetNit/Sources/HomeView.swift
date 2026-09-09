import SwiftUI
import Photos

struct HomeView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Binding var hasStartedSwiping: Bool
    @State private var showFilters = false
    @State private var showStats = false
    @State private var showSettings = false
    @State private var deviceStorage: DeviceStorage?

    struct DeviceStorage {
        let total: Int64
        let available: Int64
        let used: Int64
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("GetNit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.circle")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 24) {
                    if let stats = manager.libraryStats, let storage = deviceStorage {
                        // Device storage breakdown
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
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
                                VStack(spacing: 6) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            // Total bar
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.white.opacity(0.15))
                                                .frame(height: 12)

                                            // Used bar
                                            let usedFraction = CGFloat(storage.used) / CGFloat(storage.total)
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.orange)
                                                .frame(width: geo.size.width * usedFraction, height: 12)

                                            // Photos portion overlay
                                            if stats.estimatedStorage > 0 {
                                                let photoFraction = CGFloat(stats.estimatedStorage) / CGFloat(storage.total)
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.blue)
                                                    .frame(width: geo.size.width * photoFraction, height: 12)
                                            }
                                        }
                                    }
                                    .frame(height: 12)

                                    HStack(spacing: 16) {
                                        LegendDot(color: .blue, label: "Photos", value: ByteCountFormatter.string(fromByteCount: stats.estimatedStorage, countStyle: .file))
                                        LegendDot(color: .orange, label: "Other", value: ByteCountFormatter.string(fromByteCount: max(0, storage.used - stats.estimatedStorage), countStyle: .file))
                                        LegendDot(color: .gray, label: "Free", value: ByteCountFormatter.string(fromByteCount: storage.available, countStyle: .file))
                                    }
                                    .font(.caption)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)

                            // Quick stats grid
                            HStack(spacing: 12) {
                                QuickStatCard(icon: "photo.stack.fill", color: .blue, label: "Photos", value: "\(stats.totalPhotos)")
                                QuickStatCard(icon: "camera.viewfinder", color: .purple, label: "Screenshots", value: "\(stats.totalScreenshots)")
                                QuickStatCard(icon: "doc.on.doc.fill", color: .red, label: "Duplicates", value: "\(manager.duplicateGroups.count)")
                            }

                            // Marked for deletion (if any)
                            if !manager.markedForDeletion.isEmpty {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.pink)
                                    Text("\(manager.markedForDeletion.count) photos marked for deletion")
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                }
                                .padding()
                                .background(Color.pink.opacity(0.15))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        ProgressView("Loading library...")
                            .foregroundColor(.white)
                            .padding(.top, 40)
                    }

                    Spacer(minLength: 20)

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
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear { loadDeviceStorage() }
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
    }
}
