import SwiftUI
import Photos

struct HomeView: View {
    @ObservedObject var manager: PhotoLibraryManager
    @Binding var hasStartedSwiping: Bool
    @State private var showFilters = false
    @State private var showStats = false
    @State private var showSettings = false

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
                    // Stats summary cards
                    if let stats = manager.libraryStats {
                        VStack(spacing: 16) {
                            // Storage card (big)
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "internaldrive.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Library Storage")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(ByteCountFormatter.string(fromByteCount: stats.estimatedStorage, countStyle: .file))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
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
