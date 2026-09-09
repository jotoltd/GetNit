import SwiftUI

struct SwipeTutorialView: View {
    @Binding var isPresented: Bool
    @State private var animateHand = false
    @State private var step = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Tutorial card mockup
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 240, height: 320)

                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))

                        Text("Your Photo")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    // Animated hand
                    Image(systemName: "hand.point.right.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .offset(x: animateHand ? 150 : -100)
                        .opacity(animateHand ? 0 : 1)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: animateHand)
                }

                // Step content
                VStack(spacing: 12) {
                    if step == 0 {
                        Text("Swipe Right to Keep")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Swipe the photo right to keep it in your library")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Swipe Left to Delete")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Swipe the photo left to mark it for deletion")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Navigation buttons
                HStack(spacing: 16) {
                    if step == 1 {
                        Button(action: { step = 0 }) {
                            Text("Back")
                                .font(.headline)
                                .frame(width: 100)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }

                    Button(action: {
                        if step == 0 {
                            withAnimation { step = 1 }
                            animateHand = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                animateHand = true
                            }
                        } else {
                            isPresented = false
                        }
                    }) {
                        Text(step == 0 ? "Next" : "Got It!")
                            .font(.headline)
                            .frame(width: 120)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            animateHand = true
        }
    }
}
