import SwiftUI
import Photos

struct SwipeCardView: View {
    let image: UIImage
    let photoDate: Date?
    let onKeep: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGSize = .zero
    @State private var hasTriggeredHaptic = false

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
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        hasTriggeredHaptic = true
                    } else if !crossed {
                        hasTriggeredHaptic = false
                    }
                }
                .onEnded { _ in
                    if offset.width > threshold {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onKeep()
                            offset = .zero
                        }
                    } else if offset.width < -threshold {
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                            offset = .zero
                        }
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                    hasTriggeredHaptic = false
                }
        )
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
}
