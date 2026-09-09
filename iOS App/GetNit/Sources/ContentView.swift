import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var manager = PhotoLibraryManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("hasSeenSwipeTutorial") private var hasSeenSwipeTutorial = false
    @State private var hasStartedSwiping = false
    @State private var showFilters = false
    @State private var showSettings = false
    @State private var showMetadata = false
    @State private var showStats = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            } else if manager.authorizationStatus == .notDetermined {
                welcomeView
            } else if manager.authorizationStatus == .authorized || manager.authorizationStatus == .limited {
                if hasStartedSwiping && !manager.isComplete {
                    ZStack {
                        photoStack
                        if !hasSeenSwipeTutorial {
                            SwipeTutorialView(isPresented: Binding(
                                get: { !hasSeenSwipeTutorial },
                                set: { newValue in
                                    if !newValue { hasSeenSwipeTutorial = true }
                                }
                            ))
                        }
                    }
                } else if hasStartedSwiping && manager.isComplete {
                    summaryView
                } else {
                    HomeView(manager: manager, hasStartedSwiping: $hasStartedSwiping)
                }
            } else {
                deniedView
            }
        }
        .onAppear {
            if hasSeenOnboarding {
                manager.checkAuthorization()
            }
        }
        .onChange(of: hasSeenOnboarding) { _, seen in
            if seen { manager.checkAuthorization() }
        }
        .onChange(of: manager.isComplete) { _, complete in
            if complete { hasStartedSwiping = false }
        }
        .sheet(isPresented: $showFilters) {
            FilterView(manager: manager)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(manager: manager)
        }
        .sheet(isPresented: $showStats) {
            StatsView(manager: manager)
        }
        .sheet(isPresented: $showMetadata) {
            if manager.hasPhotos {
                PhotoMetadataView(asset: manager.assets[manager.currentIndex])
            }
        }
    }

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        VStack(spacing: 20) {
            Text("GetNit")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Swipe right to keep, left to delete.")
                .font(.title3)
            Button("Allow Photo Access") {
                manager.requestAuthorization()
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .foregroundColor(.white)
    }

    // MARK: - Denied

    private var deniedView: some View {
        VStack(spacing: 16) {
            Text("Photo access is required.")
                .font(.title2)
            Text("Please enable it in Settings > Privacy & Security > Photos.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .foregroundColor(.white)
        .padding()
    }

    // MARK: - Photo Stack

    private var photoStack: some View {
        VStack(spacing: 0) {
            // Progress bar
            if manager.assets.count > 0 {
                ProgressView(value: Double(manager.currentIndex), total: Double(manager.assets.count))
                    .tint(.white)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }

            // Top bar: counters + filter + undo
            HStack {
                Button(action: {
                    hasStartedSwiping = false
                }) {
                    Image(systemName: "house.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                Text("\(manager.currentIndex + 1) / \(manager.assets.count)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                if !manager.markedForDeletion.isEmpty {
                    Text("\(manager.markedForDeletion.count) marked")
                        .font(.subheadline)
                        .foregroundColor(.red.opacity(0.8))
                }

                Button(action: { showFilters = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                Button(action: { showStats = true }) {
                    Image(systemName: "chart.bar.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .padding(.leading, 4)

                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .padding(.leading, 4)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Card stack
            ZStack {
                // Background cards (stack depth)
                ForEach(Array((1...3).reversed()), id: \.self) { stackOffset in
                    let idx = manager.currentIndex + stackOffset
                    if idx < manager.assets.count, let img = manager.upcomingImages[idx] {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(16)
                            .scaleEffect(1.0 - CGFloat(stackOffset) * 0.05)
                            .opacity(1.0 - Double(stackOffset) * 0.25)
                            .offset(y: CGFloat(stackOffset) * 8)
                            .padding()
                    }
                }

                // Interactive top card
                if let image = manager.currentImage, manager.hasPhotos {
                    SwipeCardView(
                        image: image,
                        photoDate: manager.assets[manager.currentIndex].creationDate,
                        onKeep: { manager.keepCurrent() },
                        onDelete: { manager.markCurrentForDeletion() },
                        onLongPress: { showMetadata = true }
                    )
                    .id(manager.currentIndex)
                    .transition(.opacity)
                    .padding()
                }
            }

            // Undo button
            if manager.canUndo {
                Button(action: {
                    haptic(.light)
                    manager.undoLastSwipe()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Undo")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
                .padding(.top, 4)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 40) {
                Button(action: {
                    haptic(.medium)
                    manager.markCurrentForDeletion()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                }

                Button(action: {
                    hapticNotification(.success)
                    manager.keepCurrent()
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Summary

    private var summaryView: some View {
        VStack(spacing: 20) {
            if manager.assets.isEmpty && manager.markedForDeletion.isEmpty {
                emptyStateView
            } else if manager.assets.isEmpty {
                allCaughtUpView
            } else if manager.markedForDeletion.isEmpty {
                allKeptView
            } else {
                deleteConfirmationView
            }
        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))

            Text("No photos found")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("No photos match your current filters. Try adjusting them to see more photos.")
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: { showFilters = true }) {
                Text("Change Filters")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: { manager.clearReviewHistory() }) {
                Text("Reset Review History")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }

    private var allCaughtUpView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)

            Text("All caught up!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if manager.showStorageFreed && manager.lastDeletedSize > 0 {
                VStack(spacing: 6) {
                    Text("Storage freed:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text(manager.lastDeletedSizeFormatted)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 10)
            }

            Text("You've reviewed all your photos. New photos will appear here next time.")
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: { showFilters = true }) {
                Text("Change Filters")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: { hasStartedSwiping = false }) {
                Text("Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: { manager.clearReviewHistory() }) {
                Text("Reset Review History")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }

    private var allKeptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)

            Text("All kept!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("You didn't mark any photos for deletion.")
                .foregroundColor(.white.opacity(0.7))

            Button(action: { manager.restart() }) {
                Text("Start Over")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: { hasStartedSwiping = false }) {
                Text("Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    private var deleteConfirmationView: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)

                    Text("Delete \(manager.markedForDeletion.count) photo\(manager.markedForDeletion.count == 1 ? "" : "s")?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("This action cannot be undone.")
                        .foregroundColor(.white.opacity(0.7))

                    ReviewGridView(manager: manager)
                }
            }

            if manager.isDeleting {
                ProgressView("Deleting...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 12) {
                    Button(action: {
                        hapticNotification(.warning)
                        manager.performBatchDelete { _ in }
                    }) {
                        Text("Delete \(manager.markedForDeletion.count) Photo\(manager.markedForDeletion.count == 1 ? "" : "s")")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        manager.cancelDeletions()
                        manager.restart()
                    }) {
                        Text("Keep All & Start Over")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
