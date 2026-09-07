export const metadata = {
  title: "Support — GetNit",
  description: "Get help and support for GetNit.",
};

export default function SupportPage() {
  return (
    <div className="min-h-screen pt-32 pb-24 px-6">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-4xl font-bold mb-2">Support</h1>
        <p className="text-white/40 mb-12">We're here to help.</p>

        <div className="space-y-8">
          <section>
            <h2 className="text-2xl font-semibold text-white mb-4">Frequently asked questions</h2>
            <div className="space-y-4">
              <SupportFaq
                question="How do I undo a swipe?"
                answer="Tap the Undo button below the card. You can undo as many swipes as you want."
              />
              <SupportFaq
                question="Photos aren't showing up"
                answer="Make sure you've granted photo access in Settings > Privacy & Security > Photos > GetNit. If you chose 'Limited' access, you may need to select more photos."
              />
              <SupportFaq
                question="Can I get deleted photos back?"
                answer="No. When you confirm deletion, photos are permanently removed from your library and iCloud. That's why we show a review screen first — use it!"
              />
              <SupportFaq
                question="How do I reset which photos I've reviewed?"
                answer="Open the Filters screen (tap the filter icon) and tap 'Clear Review History'."
              />
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-4">Contact us</h2>
            <p className="text-white/60 mb-4">
              Have a question, bug report, or feature request? Send us an email:
            </p>
            <a
              href="mailto:support@getnit.app"
              className="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 px-6 py-3 rounded-full transition"
            >
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              support@getnit.app
            </a>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-white mb-4">Privacy</h2>
            <p className="text-white/60">
              Read our <a href="/privacy" className="text-green-400 hover:underline">Privacy Policy</a> to learn
              how we protect your data (spoiler: we don't collect any).
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

function SupportFaq({ question, answer }: { question: string; answer: string }) {
  return (
    <details className="group rounded-xl border border-white/10 bg-white/[0.02] overflow-hidden">
      <summary className="flex items-center justify-between p-4 cursor-pointer list-none hover:bg-white/[0.04] transition">
        <span className="font-medium">{question}</span>
        <svg className="w-5 h-5 text-white/40 group-open:rotate-180 transition" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </summary>
      <div className="px-4 pb-4 text-white/60">{answer}</div>
    </details>
  );
}
