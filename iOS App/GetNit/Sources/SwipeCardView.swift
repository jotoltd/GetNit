import SwiftUI
import Photos
import PhotosUI
import AVKit
import AVFoundation

struct SwipeCardView: View {
    let image: UIImage
    let photoDate: Date?
    let isVideo: Bool
    let videoDuration: TimeInterval?
    let videoAsset: PHAsset?
    let onKeep: () -> Void
    let onDelete: () -> Void
    let onLongPress: () -> Void

    @State private var offset: CGSize = .zero
    @State private var hasTriggeredHaptic = false
    @State private var showVideoPlayer = false
    @State private var playerItem: AVPlayerItem?
    @State private var isLoadingVideo = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    private let threshold: CGFloat = 120

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(16)
                .shadow(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 4)
                )

            HStack {
                Text("DELETE")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .opacity(Double(min(max(-offset.width, 0) / threshold, 1)))
                    .rotationEffect(.degrees(-8))
                    .padding(.leading, 20)

                Spacer()

                Text("KEEP")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .opacity(Double(min(max(offset.width, 0) / threshold, 1)))
                    .rotationEffect(.degrees(8))
                    .padding(.trailing, 20)
            }

            // Date overlay
            if let date = photoDate {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .cornerRadius(6)
                            .padding(.bottom, 8)
                            .padding(.trailing, 8)
                    }
                }
            }

            // Video badge - tap to play
            if isVideo {
                VStack {
                    Spacer()
                    Button(action: {
                        loadAndPlayVideo()
                    }) {
                        HStack {
                            if isLoadingVideo {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            if let duration = videoDuration {
                                Text(formatDuration(duration))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                    // Trigger haptic when crossing threshold
                    let crossed = abs(offset.width) > threshold
                    if crossed && !hasTriggeredHaptic {
                        if hapticsEnabled {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        hasTriggeredHaptic = true
                    } else if !crossed {
                        hasTriggeredHaptic = false
                    }
                }
                .onEnded { _ in
                    if offset.width > threshold {
                        if hapticsEnabled {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onKeep()
                        }
                    } else if offset.width < -threshold {
                        if hapticsEnabled {
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        }
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                        }
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                    hasTriggeredHaptic = false
                }
        )
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress()
        }
        .fullScreenCover(isPresented: $showVideoPlayer, onDismiss: {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }) {
            if let item = playerItem {
                VideoPlayerView(playerItem: item)
            }
        }
    }

    private func loadAndPlayVideo() {
        guard let asset = videoAsset, !isLoadingVideo else { return }
        isLoadingVideo = true
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.version = .current

        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { item, _ in
            DispatchQueue.main.async {
                self.isLoadingVideo = false
                if let item {
                    self.playerItem = item
                    self.showVideoPlayer = true
                }
            }
        }
    }

    private var borderColor: Color {
        if offset.width > threshold / 2 {
            return .green
        } else if offset.width < -threshold / 2 {
            return .red
        } else {
            return .clear
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let playerItem: AVPlayerItem

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        // Switch to playback category so audio isn't silenced by the mute switch
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)

        let controller = AVPlayerViewController()
        let player = AVPlayer(playerItem: playerItem)
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        controller.videoGravity = .resizeAspect

        player.actionAtItemEnd = .pause
        player.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
