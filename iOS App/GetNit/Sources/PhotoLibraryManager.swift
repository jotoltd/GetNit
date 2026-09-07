import SwiftUI
import Photos

struct FilterOptions: Equatable {
    var album: PHAssetCollection?
    var screenshotsOnly: Bool = false
    var startDate: Date?
    var endDate: Date?
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

    private let reviewedKey = "com.getnit.reviewedAssets"
    private let rememberKey = "com.getnit.rememberReviewed"
    private let imageManager = PHImageManager.default()
    private var currentRequestID: PHImageRequestID?
    private var nextRequestID: PHImageRequestID?
    private let targetSize = CGSize(width: 800, height: 1200)

    var hasPhotos: Bool { !assets.isEmpty && currentIndex < assets.count }
    var remainingCount: Int { assets.count - currentIndex }
    var canUndo: Bool { !history.isEmpty }

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

    // MARK: - Loading Assets

    func loadAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

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
            loadCurrentImage()
        }
    }

    // MARK: - Batch Delete

    func performBatchDelete(completion: @escaping (Bool) -> Void) {
        let toDelete = Array(markedForDeletion)
        guard !toDelete.isEmpty else {
            completion(true)
            return
        }

        isDeleting = true
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(toDelete as NSArray)
        }) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isDeleting = false
                if success {
                    self?.markedForDeletion.removeAll()
                }
                completion(success)
            }
        }
    }

    func cancelDeletions() {
        markedForDeletion.removeAll()
    }

    func restart() {
        currentIndex = 0
        markedForDeletion.removeAll()
        history.removeAll()
        isComplete = assets.isEmpty
        loadCurrentImage()
    }
}
