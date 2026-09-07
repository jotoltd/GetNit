import SwiftUI
import Photos

struct PhotoThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
                    .overlay(ProgressView())
            }
        }
        .clipped()
        .onAppear { loadImage() }
    }

    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { img, _ in
            DispatchQueue.main.async { self.image = img }
        }
    }
}

struct ReviewGridView: View {
    @ObservedObject var manager: PhotoLibraryManager

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Marked for deletion — tap to un-mark")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(manager.markedForDeletion), id: \.localIdentifier) { asset in
                        ZStack(alignment: .topTrailing) {
                            PhotoThumbnailView(asset: asset)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(8)

                            Button(action: {
                                withAnimation { manager.unmarkForDeletion(asset) }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                            .padding(4)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
