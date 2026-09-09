import SwiftUI
import Photos

struct PhotoMetadataView: View {
    let asset: PHAsset
    @Environment(\.dismiss) var dismiss
    @State private var fullImage: UIImage?
    @State private var fileSize: Int64 = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = fullImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                    } else {
                        ProgressView()
                            .frame(height: 400)
                    }

                    VStack(spacing: 12) {
                        metadataRow("Date", asset.creationDate?.formatted(date: .complete, time: .shortened) ?? "Unknown")
                        metadataRow("Dimensions", "\(asset.pixelWidth) × \(asset.pixelHeight) px")
                        metadataRow("File Size", ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))
                        if let loc = asset.location {
                            metadataRow("Location", String(format: "%.4f, %.4f", loc.coordinate.latitude, loc.coordinate.longitude))
                        }
                        metadataRow("Type", asset.mediaType == .image ? "Photo" : "Other")
                        metadataRow("Source", asset.sourceType == .typeUserLibrary ? "Your Library" : "iTunes/Cloud")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Photo Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear { loadData() }
    }

    private func metadataRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }

    private func loadData() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 1200, height: 1200),
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async { self.fullImage = image }
        }

        // Get file size
        let resources = PHAssetResource.assetResources(for: asset)
        var totalSize: Int64 = 0
        for resource in resources {
            if let size = resource.value(forKey: "fileSize") as? Int64 {
                totalSize += size
            }
        }
        fileSize = totalSize
    }
}
