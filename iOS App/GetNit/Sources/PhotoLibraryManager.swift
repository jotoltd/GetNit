import SwiftUI
import Photos

struct FilterOptions: Equatable {
    var album: PHAssetCollection?
    var screenshotsOnly: Bool = false
    var videosOnly: Bool = false
    var startDate: Date?
    var endDate: Date?
    var duplicatesOnly: Bool = false
    var sortOption: SortOption = .newestFirst
}

enum SortOption: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case largestFirst = "Largest First"
    case smallestFirst = "Smallest First"
}

struct LibraryStats {
    let totalPhotos: Int
    let totalVideos: Int
    let totalScreenshots: Int
    let totalDuplicates: Int
    let estimatedStorage: Int64
}

enum SwipeAction: Equatable {
    case keep
    case markForDeletion
}

struct SwipeHistoryEntry: Identifiable {
    let id = UUID()
    let asset: PHAsset
    let action: SwipeAction
    let index: Int
}

final class PhotoLibraryManager: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var currentIndex: Int = 0
    @Published var currentImage: UIImage?
    @Published var nextImage: UIImage?
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var markedForDeletion: Set<PHAsset> = []
    @Published var isComplete: Bool = false
    @Published var isDeleting: Bool = false
    @Published var filters = FilterOptions()
    @Published var albums: [PHAssetCollection] = []
    @Published var history: [SwipeHistoryEntry] = []
    @Published var rememberReviewed: Bool = true
    @Published var lastDeletedSize: Int64 = 0
    @Published var showStorageFreed: Bool = false
    @Published var duplicateGroups: [[PHAsset]] = []
    @Published var upcomingImages: [Int: UIImage] = [:]
    @Published var libraryStats: LibraryStats?
    @Published var currentAssetIsVideo: Bool = false

    private let reviewedKey = "com.getnit.reviewedAssets"
    private let rememberKey = "com.getnit.rememberReviewed"
    private let imageManager = PHImageManager.default()
    private var currentRequestID: PHImageRequestID?
    private var nextRequestID: PHImageRequestID?
    private var stackRequestIDs: [PHImageRequestID] = []
    private let targetSize = CGSize(width: 800, height: 1200)

    var hasPhotos: Bool { !assets.isEmpty && currentIndex < assets.count }
    var remainingCount: Int { assets.count - currentIndex }
    var canUndo: Bool { !history.isEmpty }
    var duplicateCount: Int { duplicateGroups.reduce(0) { $0 + $1.count } }

    init() {
        rememberReviewed = UserDefaults.standard.object(forKey: rememberKey) as? Bool ?? true
    }

    // MARK: - Persistence

    private func loadReviewed() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: reviewedKey) ?? [])
    }

    private func saveReviewed(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: reviewedKey)
    }

    func clearReviewHistory() {
        UserDefaults.standard.removeObject(forKey: reviewedKey)
        loadAssets()
    }

    func setRememberReviewed(_ value: Bool) {
        rememberReviewed = value
        UserDefaults.standard.set(value, forKey: rememberKey)
    }

    // MARK: - Library Stats

    func calculateLibraryStats() {
        DispatchQueue.global(qos: .utility).async {
            let options = PHFetchOptions()
            // Fetch ALL assets (images + videos), not just .image
            let allAssets = PHAsset.fetchAssets(with: options)

            var total = 0
            var screenshots = 0
            var videos = 0

            allAssets.enumerateObjects { asset, _, _ in
                guard asset.mediaType == .image || asset.mediaType == .video else { return }
                total += 1
                if asset.mediaSubtypes.contains(.photoScreenshot) {
                    screenshots += 1
                }
                if asset.mediaType == .video {
                    videos += 1
                }
            }

            // Estimate storage from average photo size
            // Avoids expensive PHAssetResource call per photo
            let estimatedSize = Int64(total) * 2_500_000 // ~2.5MB avg

            DispatchQueue.main.async {
                self.libraryStats = LibraryStats(
                    totalPhotos: total - videos,
                    totalVideos: videos,
                    totalScreenshots: screenshots,
                    totalDuplicates: self.duplicateGroups.reduce(0) { $0 + $1.count },
                    estimatedStorage: estimatedSize
                )
            }
        }
    }

    // MARK: - Authorization

    func checkAuthorization() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorizationStatus == .authorized || authorizationStatus == .limited {
            loadAlbums()
            loadAssets()
        }
    }

    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self?.loadAlbums()
                    self?.loadAssets()
                }
            }
        }
    }

    // MARK: - Albums

    func loadAlbums() {
        var found: [PHAssetCollection] = []
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smartAlbums.enumerateObjects { col, _, _ in found.append(col) }
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        userAlbums.enumerateObjects { col, _, _ in found.append(col) }
        albums = found
    }

    // MARK: - Duplicate Detection

    func detectDuplicates(in assets: [PHAsset]) -> [[PHAsset]] {
        // Group by similar creation date (within 5 seconds) and same pixel size
        let sorted = assets.sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
        var groups: [[PHAsset]] = []
        var currentGroup: [PHAsset] = []

        for asset in sorted {
            if let last = currentGroup.last,
               let lastDate = last.creationDate,
               let assetDate = asset.creationDate,
               abs(lastDate.timeIntervalSince(assetDate)) < 5,
               last.pixelWidth == asset.pixelWidth,
               last.pixelHeight == asset.pixelHeight {
                currentGroup.append(asset)
            } else {
                if currentGroup.count > 1 { groups.append(currentGroup) }
                currentGroup = [asset]
            }
        }
        if currentGroup.count > 1 { groups.append(currentGroup) }
        return groups
    }

    // MARK: - Loading Assets

    private func fetchFilteredAssets() -> [PHAsset] {
        let options = PHFetchOptions()
        switch filters.sortOption {
        case .newestFirst:
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        case .oldestFirst:
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        case .largestFirst:
            options.sortDescriptors = [NSSortDescriptor(key: "pixelWidth", ascending: false)]
        case .smallestFirst:
            options.sortDescriptors = [NSSortDescriptor(key: "pixelWidth", ascending: true)]
        }

        var predicates: [NSPredicate] = []
        if filters.screenshotsOnly {
            predicates.append(NSPredicate(format: "(mediaSubtypes & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue))
        }
        if let start = filters.startDate {
            predicates.append(NSPredicate(format: "creationDate >= %@", start as NSDate))
        }
        if let end = filters.endDate {
            predicates.append(NSPredicate(format: "creationDate <= %@", end as NSDate))
        }
        if !predicates.isEmpty {
            options.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        // Determine media type: videos only, or all (images + videos)
        let mediaType: PHAssetMediaType? = filters.videosOnly ? .video : nil

        var fetched: [PHAsset] = []
        if let album = filters.album {
            PHAsset.fetchAssets(in: album, options: options).enumerateObjects { asset, _, _ in
                if mediaType == nil || asset.mediaType == mediaType {
                    fetched.append(asset)
                }
            }
        } else if let mt = mediaType {
            PHAsset.fetchAssets(with: mt, options: options).enumerateObjects { asset, _, _ in
                fetched.append(asset)
            }
        } else {
            // Fetch both images and videos
            PHAsset.fetchAssets(with: options).enumerateObjects { asset, _, _ in
                if asset.mediaType == .image || asset.mediaType == .video {
                    fetched.append(asset)
                }
            }
        }
        return fetched
    }

    func loadAssets() {
        let fetched = fetchFilteredAssets()

        if rememberReviewed {
            let reviewed = loadReviewed()
            assets = fetched.filter { !reviewed.contains($0.localIdentifier) }
        } else {
            assets = fetched
        }

        // Detect duplicates from the full fetched set (background)
        let fetchedCopy = fetched
        DispatchQueue.global(qos: .utility).async {
            let groups = self.detectDuplicates(in: fetchedCopy)
            DispatchQueue.main.async {
                self.duplicateGroups = groups

                // If duplicatesOnly filter is on, re-filter now that we have groups
                if self.filters.duplicatesOnly {
                    let duplicateAssets = Set(groups.flatMap { $0 })
                    self.assets = self.assets.filter { duplicateAssets.contains($0) }
                    self.currentIndex = 0
                    self.isComplete = self.assets.isEmpty
                    self.loadCurrentImage()
                }
            }
        }

        // Calculate library stats (background)
        calculateLibraryStats()

        // Filter to show only duplicates if requested (will be re-filtered when groups load)
        if filters.duplicatesOnly {
            // Skip duplicate filtering here - will be done when groups arrive
        }

        currentIndex = 0
        markedForDeletion.removeAll()
        history.removeAll()
        isComplete = assets.isEmpty
        loadCurrentImage()
    }

    func loadCurrentImage() {
        if let id = currentRequestID { imageManager.cancelImageRequest(id) }
        if let id = nextRequestID { imageManager.cancelImageRequest(id) }
        for id in stackRequestIDs { imageManager.cancelImageRequest(id) }
        stackRequestIDs.removeAll()
        upcomingImages.removeAll()
        nextImage = nil

        guard currentIndex < assets.count else {
            currentImage = nil
            return
        }

        let asset = assets[currentIndex]
        currentAssetIsVideo = asset.mediaType == .video
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        currentRequestID = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, _ in
            DispatchQueue.main.async { self?.currentImage = image }
        }

        // Preload next card + stack cards
        preloadStackImages()
    }

    private func preloadStackImages() {
        // Preload next 3 images for the card stack
        for offset in 1...3 {
            let idx = currentIndex + offset
            guard idx < assets.count else { break }

            let stackAsset = assets[idx]
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true

            let reqID = imageManager.requestImage(
                for: stackAsset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { [weak self] image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self?.upcomingImages[idx] = image
                        if idx == (self?.currentIndex ?? 0) + 1 {
                            self?.nextImage = image
                        }
                    }
                }
            }
            stackRequestIDs.append(reqID)
        }
    }

    // MARK: - Swipe Actions

    func keepCurrent() {
        guard currentIndex < assets.count else { return }
        let asset = assets[currentIndex]
        history.append(SwipeHistoryEntry(asset: asset, action: .keep, index: currentIndex))
        markReviewed(asset)
        advance()
    }

    func markCurrentForDeletion() {
        guard currentIndex < assets.count else { return }
        let asset = assets[currentIndex]
        markedForDeletion.insert(asset)
        history.append(SwipeHistoryEntry(asset: asset, action: .markForDeletion, index: currentIndex))
        markReviewed(asset)
        advance()
    }

    func undoLastSwipe() {
        guard let last = history.last else { return }
        history.removeLast()
        if last.action == .markForDeletion {
            markedForDeletion.remove(last.asset)
        }
        unmarkReviewed(last.asset)
        currentIndex = last.index
        isComplete = false
        loadCurrentImage()
    }

    func unmarkForDeletion(_ asset: PHAsset) {
        markedForDeletion.remove(asset)
    }

    private func markReviewed(_ asset: PHAsset) {
        guard rememberReviewed else { return }
        var reviewed = loadReviewed()
        reviewed.insert(asset.localIdentifier)
        saveReviewed(reviewed)
    }

    private func unmarkReviewed(_ asset: PHAsset) {
        guard rememberReviewed else { return }
        var reviewed = loadReviewed()
        reviewed.remove(asset.localIdentifier)
        saveReviewed(reviewed)
    }

    private func advance() {
        currentIndex += 1
        if currentIndex >= assets.count {
            isComplete = true
            currentImage = nil
            nextImage = nil
            upcomingImages.removeAll()
        } else {
            // Immediately swap to preloaded image to avoid flashing old photo
            if let next = upcomingImages[currentIndex] {
                currentImage = next
                upcomingImages.removeValue(forKey: currentIndex)
                nextImage = upcomingImages[currentIndex + 1]
                // Preload more images to keep the stack filled
                preloadStackImages()
            } else if let next = nextImage {
                currentImage = next
                nextImage = nil
                preloadStackImages()
            } else {
                loadCurrentImage()
            }
        }
    }

    private func preloadNextImage() {
        preloadStackImages()
    }

    // MARK: - Batch Delete

    /// Marks every asset matching the current filters for deletion, ignoring review history.
    func markAllForDeletion() {
        if filters.duplicatesOnly {
            markedForDeletion = Set(duplicateGroups.flatMap { $0 })
        } else {
            markedForDeletion = Set(fetchFilteredAssets())
        }
        isComplete = true
    }

    func performBatchDelete(completion: @escaping (Bool) -> Void) {
        let toDelete = Array(markedForDeletion)
        guard !toDelete.isEmpty else {
            completion(true)
            return
        }

        // Calculate total size before deleting
        lastDeletedSize = toDelete.reduce(Int64(0)) { $0 + Int64($1.value(forKey: "pixelFileSize") as? Int ?? 0) }

        isDeleting = true
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
        }) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isDeleting = false
                if success {
                    self?.markedForDeletion.removeAll()
                    self?.showStorageFreed = true
                    self?.loadAssets()
                }
                completion(success)
            }
        }
    }

    func cancelDeletions() {
        markedForDeletion.removeAll()
    }

    var lastDeletedSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: lastDeletedSize, countStyle: .file)
    }

    func restart() {
        currentIndex = 0
        markedForDeletion.removeAll()
        history.removeAll()
        isComplete = assets.isEmpty
        loadCurrentImage()
    }
}
