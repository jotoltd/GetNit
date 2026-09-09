import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var animateLogo = false
    @State private var animateRows = false
    @State private var animateButton = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Logo with bounce-in animation
            VStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateLogo ? 1.0 : 0.5)
                    .opacity(animateLogo ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: animateLogo)

                Text("GetNit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(animateLogo ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.4).delay(0.3), value: animateLogo)
            }

            Text("Clean up your gallery with a swipe.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
                .opacity(animateLogo ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.4).delay(0.5), value: animateLogo)

            VStack(spacing: 36) {
                OnboardingRow(icon: "checkmark.circle.fill", color: .green, title: "Swipe Right", subtitle: "Keep the photo")
                    .offset(x: animateRows ? 0 : -50)
                    .opacity(animateRows ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateRows)
                OnboardingRow(icon: "xmark.circle.fill", color: .red, title: "Swipe Left", subtitle: "Mark for deletion")
                    .offset(x: animateRows ? 0 : -50)
                    .opacity(animateRows ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateRows)
                OnboardingRow(icon: "trash.fill", color: .white, title: "Review & Confirm", subtitle: "Batch-delete all marked photos at the end")
                    .offset(x: animateRows ? 0 : -50)
                    .opacity(animateRows ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateRows)
            }
            .padding(.top, 20)

            Spacer()

            Button("Get Started") {
                hasSeenOnboarding = true
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(12)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .scaleEffect(animateButton ? 1.0 : 0.8)
            .opacity(animateButton ? 1.0 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6), value: animateButton)
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            animateLogo = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animateRows = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateButton = true
            }
        }
    }
}

private struct OnboardingRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
    }
}
