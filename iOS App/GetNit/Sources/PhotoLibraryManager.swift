import SwiftUI
import Photos

struct FilterOptions: Equatable {
    var album: PHAssetCollection?
    var screenshotsOnly: Bool = false
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

    private let reviewedKey = "com.getnit.reviewedAssets"
    private let rememberKey = "com.getnit.rememberReviewed"
    private let imageManager = PHImageManager.default()
    private var currentRequestID: PHImageRequestID?
    private var nextRequestID: PHImageRequestID?
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

    func loadAssets() {
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

        var fetched: [PHAsset] = []
        if let album = filters.album {
            PHAsset.fetchAssets(in: album, options: options).enumerateObjects { asset, _, _ in
                fetched.append(asset)
            }
        } else {
            PHAsset.fetchAssets(with: .image, options: options).enumerateObjects { asset, _, _ in
                fetched.append(asset)
            }
        }

        if rememberReviewed {
            let reviewed = loadReviewed()
            assets = fetched.filter { !reviewed.contains($0.localIdentifier) }
        } else {
            assets = fetched
        }

        // Detect duplicates from the full fetched set
        duplicateGroups = detectDuplicates(in: fetched)

        // Filter to show only duplicates if requested
        if filters.duplicatesOnly {
            let duplicateAssets = Set(duplicateGroups.flatMap { $0 })
            assets = assets.filter { duplicateAssets.contains($0) }
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
        nextImage = nil

        guard currentIndex < assets.count else {
            currentImage = nil
            return
        }

        let asset = assets[currentIndex]
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

        // Preload next card for stack animation
        if currentIndex + 1 < assets.count {
            let nextAsset = assets[currentIndex + 1]
            nextRequestID = imageManager.requestImage(
                for: nextAsset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { [weak self] image, _ in
                DispatchQueue.main.async { self?.nextImage = image }
            }
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
        } else {
            // Immediately swap to preloaded next image to avoid flashing old photo
            if let next = nextImage {
                currentImage = next
                nextImage = nil
                // Preload the next-next image
                preloadNextImage()
            } else {
                loadCurrentImage()
            }
        }
    }

    private func preloadNextImage() {
        if let id = nextRequestID { imageManager.cancelImageRequest(id) }
        nextImage = nil

        guard currentIndex + 1 < assets.count else { return }

        let nextAsset = assets[currentIndex + 1]
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        nextRequestID = imageManager.requestImage(
            for: nextAsset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, _ in
            DispatchQueue.main.async { self?.nextImage = image }
        }
    }

    // MARK: - Batch Delete

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
