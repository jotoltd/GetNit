export const metadata = {
  title: "Privacy Policy — GetNit",
  description: "How GetNit handles your data and protects your privacy.",
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen pt-32 pb-24 px-6">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-4xl font-bold mb-2">Privacy Policy</h1>
        <p className="text-white/40 mb-12">Last updated: September 7, 2026</p>

        <div className="space-y-8 text-white/70 leading-relaxed">
          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">The short version</h2>
            <p>
              GetNit does not collect, store, or transmit any of your personal data or photos.
              Everything happens on your device. We have no servers, no databases, and no analytics.
              We literally cannot see your photos.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">Photo library access</h2>
            <p>
              GetNit requests access to your photo library via the iOS Photos framework (PhotoKit)
              solely to display your photos so you can swipe through them and choose which to keep or delete.
              When you confirm a deletion, the photos are removed from your library through the standard iOS
              deletion API. This action is irreversible.
            </p>
            <p className="mt-3">
              Photo access is requested with <code className="text-green-400">readWrite</code> permission
              so that deletions can be performed. You can revoke this access at any time in
              Settings &gt; Privacy &amp; Security &gt; Photos.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">No data collection</h2>
            <p>We do not collect any of the following:</p>
            <ul className="list-disc list-inside mt-3 space-y-1">
              <li>Personal information (name, email, phone number)</li>
              <li>Photos or videos</li>
              <li>Usage analytics or crash reports</li>
              <li>Device identifiers</li>
              <li>Location data</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">Local storage</h2>
            <p>
              GetNit stores the following data locally on your device using iOS UserDefaults:
            </p>
            <ul className="list-disc list-inside mt-3 space-y-1">
              <li>Whether you have seen the onboarding screen</li>
              <li>Local identifiers of photos you have already reviewed (so they don't reappear)</li>
              <li>Your filter and "remember reviewed" preferences</li>
            </ul>
            <p className="mt-3">
              This data never leaves your device. You can clear it at any time from the
              Filters screen by tapping "Clear Review History" or by deleting the app.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">No third-party services</h2>
            <p>
              GetNit does not use any third-party SDKs, analytics tools, advertising networks,
              or cloud services. There are no trackers, no ads, and no background data transfer.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">Children's privacy</h2>
            <p>
              GetNit does not knowingly collect any data from anyone, including children under 13.
              The app does not require an account or any personal information to use.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">Changes to this policy</h2>
            <p>
              If we ever change this privacy policy, we will update this page. Since we collect no data,
              any changes would only relate to how the app operates locally on your device.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-3">Contact</h2>
            <p>
              If you have questions about this privacy policy, please visit our{" "}
              <a href="/support" className="text-green-400 hover:underline">support page</a>.
            </p>
          </section>
        </div>

        <div className="mt-12 pt-8 border-t border-white/10">
          <a href="/" className="text-green-400 hover:underline">← Back to home</a>
        </div>
      </div>
    </div>
  );
}
