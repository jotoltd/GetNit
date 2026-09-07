import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("GetNit")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Clean up your gallery with a swipe.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))

            VStack(spacing: 36) {
                OnboardingRow(icon: "checkmark.circle.fill", color: .green, title: "Swipe Right", subtitle: "Keep the photo")
                OnboardingRow(icon: "xmark.circle.fill", color: .red, title: "Swipe Left", subtitle: "Mark for deletion")
                OnboardingRow(icon: "trash.fill", color: .white, title: "Review & Confirm", subtitle: "Batch-delete all marked photos at the end")
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
        }
        .background(Color.black.ignoresSafeArea())
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
