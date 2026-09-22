export default function Home() {
  return (
    <div className="flex flex-col min-h-screen">do it 
      {/* Nav */}
      <nav className="fixed top-0 w-full z-50 backdrop-blur-lg bg-black/60 border-b border-white/10">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <span className="text-2xl font-bold tracking-tight">GetNit</span>
          <div className="hidden md:flex items-center gap-8 text-sm text-white/70">
            <a href="#features" className="hover:text-white transition">Features</a>
            <a href="#how" className="hover:text-white transition">How it works</a>
            <a href="#faq" className="hover:text-white transition">FAQ</a>
          </div>
          <a href="#download" className="bg-white text-black px-5 py-2 rounded-full text-sm font-semibold hover:bg-white/90 transition">
            Download
          </a>
        </div>
      </nav>

      {/* Hero */}
      <section className="relative pt-40 pb-24 px-6 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-green-500/10 via-transparent to-transparent" />
        <div className="absolute top-20 left-10 w-72 h-72 bg-green-500/20 rounded-full blur-3xl" />
        <div className="absolute top-40 right-10 w-72 h-72 bg-red-500/20 rounded-full blur-3xl" />

        <div className="relative max-w-7xl mx-auto grid md:grid-cols-2 gap-12 items-center">
          <div>
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/10 text-sm text-white/80 mb-6">
              <span className="w-2 h-2 rounded-full bg-green-500" />
              Now available on iOS
            </div>
            <h1 className="text-5xl md:text-7xl font-bold tracking-tight leading-[1.05]">
              Clean up your gallery with a{" "}
              <span className="bg-gradient-to-r from-green-400 to-emerald-500 bg-clip-text text-transparent">
                swipe
              </span>
              .
            </h1>
            <p className="mt-6 text-xl text-white/60 max-w-lg">
              GetNit is the fastest way to declutter your iPhone photos. Swipe right to keep, left to delete. Like Tinder, but for your camera roll.
            </p>
            <div className="mt-8 flex flex-wrap gap-4">
              <a href="#download" className="bg-white text-black px-8 py-4 rounded-full font-semibold text-lg hover:bg-white/90 transition flex items-center gap-2">
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.09 1.85-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
                </svg>
                Download on iOS
              </a>
              <a href="#how" className="border border-white/20 px-8 py-4 rounded-full font-semibold text-lg hover:bg-white/10 transition">
                See how it works
              </a>
            </div>
            <div className="mt-10 flex items-center gap-6 text-sm text-white/50">
              <div className="flex items-center gap-1">
                <span className="text-yellow-400">★★★★★</span>
                <span className="ml-1">5.0 rating</span>
              </div>
              <div>•</div>
              <div>No ads</div>
              <div>•</div>
              <div>Private & on-device</div>
            </div>
          </div>

          {/* Phone mockup */}
          <div className="relative flex justify-center">
            <div className="relative w-72 h-[580px] animate-float">
              <div className="absolute inset-0 rounded-[3rem] border-4 border-white/20 bg-zinc-900 shadow-2xl" />
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 bg-zinc-900 rounded-b-2xl z-10" />
              <div className="absolute inset-2 rounded-[2.5rem] overflow-hidden bg-black flex flex-col items-center justify-center p-4">
                <div className="relative w-full h-full rounded-2xl bg-gradient-to-br from-zinc-700 to-zinc-900 flex items-center justify-center overflow-hidden">
                  <div className="text-6xl opacity-30">📸</div>
                  <div className="absolute top-6 left-4 px-3 py-1 rounded-lg bg-green-500/20 border-2 border-green-500 -rotate-12">
                    <span className="text-green-500 font-bold text-sm">KEEP</span>
                  </div>
                  <div className="absolute top-6 right-4 px-3 py-1 rounded-lg bg-red-500/20 border-2 border-red-500 rotate-12">
                    <span className="text-red-500 font-bold text-sm">DELETE</span>
                  </div>
                  <div className="absolute bottom-20 w-full flex justify-center gap-8">
                    <div className="w-14 h-14 rounded-full bg-red-500/20 border-2 border-red-500/50 flex items-center justify-center">
                      <svg className="w-7 h-7 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </div>
                    <div className="w-14 h-14 rounded-full bg-green-500/20 border-2 border-green-500/50 flex items-center justify-center">
                      <svg className="w-7 h-7 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                  </div>
                </div>
                <div className="mt-3 text-xs text-white/50">12 / 348 · 3 marked</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="border-y border-white/10 py-12 px-6">
        <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
          <Stat value="10x" label="Faster than manual cleanup" />
          <Stat value="0" label="Ads, ever" />
          <Stat value="100%" label="On-device, private" />
          <Stat value="1" label="Swipe to decide" />
        </div>
      </section>

      {/* Screenshots */}
      <section id="screenshots" className="py-24 px-6 overflow-hidden">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-4xl md:text-5xl font-bold text-center mb-4">
            See it in action
          </h2>
          <p className="text-center text-white/50 text-lg mb-16 max-w-2xl mx-auto">
            Four screens. One simple flow. Total control over your photo library.
          </p>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-8 justify-items-center">
            <PhoneMockup label="Onboarding">
              <div className="flex flex-col items-center justify-center h-full px-4 text-center">
                <div className="text-3xl font-bold mb-3">GetNit</div>
                <div className="text-xs text-white/60 mb-6">Clean up your gallery with a swipe.</div>
                <div className="space-y-3 w-full">
                  <div className="flex items-center gap-2 text-xs">
                    <div className="w-8 h-8 rounded-full bg-green-500/20 border border-green-500/50 flex items-center justify-center text-green-400">✓</div>
                    <span className="text-white/70">Swipe Right = Keep</span>
                  </div>
                  <div className="flex items-center gap-2 text-xs">
                    <div className="w-8 h-8 rounded-full bg-red-500/20 border border-red-500/50 flex items-center justify-center text-red-400">✕</div>
                    <span className="text-white/70">Swipe Left = Delete</span>
                  </div>
                  <div className="flex items-center gap-2 text-xs">
                    <div className="w-8 h-8 rounded-full bg-white/10 border border-white/20 flex items-center justify-center text-white/70">🗑</div>
                    <span className="text-white/70">Review & Confirm</span>
                  </div>
                </div>
                <div className="mt-6 bg-white text-black text-xs font-semibold px-4 py-2 rounded-full">Get Started</div>
              </div>
            </PhoneMockup>

            <PhoneMockup label="Swipe">
              <div className="flex flex-col h-full">
                <div className="flex justify-between text-[10px] text-white/50 px-3 pt-2">
                  <span>12 / 348</span>
                  <span className="text-red-400">3 marked</span>
                </div>
                <div className="flex-1 m-2 rounded-xl bg-gradient-to-br from-zinc-600 to-zinc-800 flex items-center justify-center relative">
                  <div className="text-4xl opacity-30">📸</div>
                  <div className="absolute top-3 left-2 px-2 py-0.5 rounded bg-green-500/20 border border-green-500 -rotate-12">
                    <span className="text-green-500 font-bold text-[10px]">KEEP</span>
                  </div>
                  <div className="absolute top-3 right-2 px-2 py-0.5 rounded bg-red-500/20 border border-red-500 rotate-12">
                    <span className="text-red-500 font-bold text-[10px]">DELETE</span>
                  </div>
                </div>
                <div className="flex justify-center gap-6 pb-3">
                  <div className="w-9 h-9 rounded-full bg-red-500/20 border border-red-500/50 flex items-center justify-center text-red-500 text-sm">✕</div>
                  <div className="w-9 h-9 rounded-full bg-green-500/20 border border-green-500/50 flex items-center justify-center text-green-500 text-sm">✓</div>
                </div>
              </div>
            </PhoneMockup>

            <PhoneMockup label="Review">
              <div className="flex flex-col h-full p-2">
                <div className="text-center text-xs text-white/70 mb-2">Marked for deletion</div>
                <div className="grid grid-cols-3 gap-1 flex-1">
                  {[...Array(9)].map((_, i) => (
                    <div key={i} className="rounded bg-gradient-to-br from-zinc-600 to-zinc-800 relative">
                      <div className="absolute top-0.5 right-0.5 w-3 h-3 rounded-full bg-red-500/80 flex items-center justify-center text-[8px]">✕</div>
                    </div>
                  ))}
                </div>
                <div className="mt-2 bg-red-500 text-white text-center text-xs font-semibold py-1.5 rounded">Delete 9 Photos</div>
              </div>
            </PhoneMockup>

            <PhoneMockup label="All done">
              <div className="flex flex-col items-center justify-center h-full px-4 text-center">
                <div className="text-4xl mb-3">✅</div>
                <div className="text-lg font-bold mb-2">All caught up!</div>
                <div className="text-xs text-white/50 mb-4">You've reviewed all your photos.</div>
                <div className="bg-white/10 text-xs px-3 py-1.5 rounded">Change Filters</div>
              </div>
            </PhoneMockup>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-24 px-6">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-4xl md:text-5xl font-bold text-center mb-4">
            Everything you need to <span className="text-green-400">take control</span>
          </h2>
          <p className="text-center text-white/50 text-lg mb-16 max-w-2xl mx-auto">
            Built from the ground up to make photo cleanup effortless, fast, and private.
          </p>
          <div className="grid md:grid-cols-3 gap-6">
            <FeatureCard icon="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4" title="Tinder-style swiping" description="Swipe right to keep, left to mark for deletion. The intuitive gesture you already know, applied to your photo gallery." />
            <FeatureCard icon="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" title="Batch delete at the end" description="Nothing is deleted until you say so. Review everything you marked, un-mark any mistakes, then confirm with one tap." />
            <FeatureCard icon="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" title="Undo any swipe" description="Made a mistake? One tap undoes your last swipe. No pressure, no permanent decisions until you're ready." />
            <FeatureCard icon="M3 4h18M4 8h14M6 12h10M8 16h6" title="Smart filters" description="Filter by album, screenshots only, or date range. Clean up just what you want — leave the rest for later." />
            <FeatureCard icon="M4 6a2 2 0 012-2h12a2 2 0 012 2v12a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM8 10h8M8 14h5" title="Review before deleting" description="See a grid of every marked photo before anything gets deleted. Tap to un-mark any you want to keep." />
            <FeatureCard icon="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" title="Remembers your progress" description="Already-reviewed photos won't show up again. Pick up where you left off, anytime." />
          </div>
        </div>
      </section>

      {/* How it works */}
      <section id="how" className="py-24 px-6 bg-gradient-to-b from-transparent via-green-500/5 to-transparent">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-4xl md:text-5xl font-bold text-center mb-16">How it works</h2>
          <div className="grid md:grid-cols-3 gap-12">
            <StepCard number="1" title="Swipe through" description="Browse your photos one by one. Swipe right to keep, left to mark for deletion. Use the buttons if you prefer tapping." />
            <StepCard number="2" title="Review your marks" description="When you're done, see a grid of everything you marked. Tap any photo to un-mark it if you changed your mind." />
            <StepCard number="3" title="Confirm & delete" description="Hit delete and all marked photos are removed from your library in one batch. Free up space instantly." />
          </div>
        </div>
      </section>

      {/* Privacy */}
      <section className="py-24 px-6">
        <div className="max-w-3xl mx-auto text-center">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-green-500/10 border border-green-500/30 mb-6">
            <svg className="w-8 h-8 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
          <h2 className="text-4xl font-bold mb-4">Your photos never leave your phone</h2>
          <p className="text-white/60 text-lg">
            GetNit works entirely on-device. No cloud uploads, no servers, no tracking. Your photos are processed locally and deletions go directly through iOS PhotoKit. We literally cannot see your photos.
          </p>
        </div>
      </section>

      {/* FAQ */}
      <section id="faq" className="py-24 px-6">
        <div className="max-w-3xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16">Frequently asked questions</h2>
          <div className="space-y-4">
            <FaqItem question="Does GetNit delete photos immediately?" answer="No. When you swipe left, the photo is only marked for deletion. Nothing is actually deleted until you reach the end and tap the confirm button. You can undo any swipe or un-mark any photo before confirming." />
            <FaqItem question="Can I undo a swipe?" answer="Yes. Tap the Undo button below the card to revert your last swipe. You can undo as many times as you want." />
            <FaqItem question="Can I filter which photos I see?" answer="Yes. Tap the filter icon to filter by album, screenshots only, or a date range. You can also choose whether GetNit remembers which photos you've already reviewed." />
            <FaqItem question="Is my data sent to a server?" answer="No. GetNit is 100% on-device. Your photos are never uploaded anywhere. All processing and deletion happens locally through iOS PhotoKit." />
            <FaqItem question="Does it work with iCloud photos?" answer="Yes. GetNit uses the standard iOS PhotoKit framework, so it works with both on-device and iCloud-synced photos. Deleting a photo removes it from your library and iCloud." />
            <FaqItem question="Is GetNit free?" answer="GetNit is free to download with no ads. Check the App Store listing for full details." />
          </div>
        </div>
      </section>

      {/* Download CTA */}
      <section id="download" className="py-24 px-6">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-4xl md:text-6xl font-bold mb-6">Ready to clean up?</h2>
          <p className="text-white/60 text-xl mb-10">Download GetNit and swipe your way to a cleaner gallery.</p>
          <a href="https://apps.apple.com/us/app/getnit-photo-cleaner/id6810416446" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-3 bg-white text-black px-10 py-5 rounded-full font-semibold text-xl hover:bg-white/90 transition glow-green">
            <svg className="w-7 h-7" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.09 1.85-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
            </svg>
            Download on the App Store
          </a>
          <p className="text-white/40 text-sm mt-6">Requires iOS 17 or later · iPhone only</p>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/10 py-12 px-6">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-center gap-2">
            <span className="text-xl font-bold">GetNit</span>
            <span className="text-white/40 text-sm">© 2026</span>
          </div>
          <div className="flex items-center gap-6 text-sm text-white/50">
            <a href="#features" className="hover:text-white transition">Features</a>
            <a href="#how" className="hover:text-white transition">How it works</a>
            <a href="#faq" className="hover:text-white transition">FAQ</a>
            <a href="/privacy" className="hover:text-white transition">Privacy Policy</a>
            <a href="/support" className="hover:text-white transition">Support</a>
          </div>
        </div>
      </footer>
    </div>
  );
}

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div>
      <div className="text-4xl font-bold text-green-400">{value}</div>
      <div className="text-sm text-white/50 mt-1">{label}</div>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: string; title: string; description: string }) {
  return (
    <div className="group p-8 rounded-2xl border border-white/10 hover:border-green-500/30 bg-white/[0.02] hover:bg-white/[0.04] transition">
      <div className="w-12 h-12 rounded-xl bg-green-500/10 border border-green-500/20 flex items-center justify-center mb-5 group-hover:scale-110 transition">
        <svg className="w-6 h-6 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d={icon} />
        </svg>
      </div>
      <h3 className="text-xl font-semibold mb-3">{title}</h3>
      <p className="text-white/50 leading-relaxed">{description}</p>
    </div>
  );
}

function StepCard({ number, title, description }: { number: string; title: string; description: string }) {
  return (
    <div className="text-center">
      <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-500/10 border-2 border-green-500/30 text-2xl font-bold text-green-400 mb-6">
        {number}
      </div>
      <h3 className="text-xl font-semibold mb-3">{title}</h3>
      <p className="text-white/50 leading-relaxed">{description}</p>
    </div>
  );
}

function FaqItem({ question, answer }: { question: string; answer: string }) {
  return (
    <details className="group rounded-xl border border-white/10 bg-white/[0.02] overflow-hidden">
      <summary className="flex items-center justify-between p-5 cursor-pointer list-none hover:bg-white/[0.04] transition">
        <span className="font-semibold text-lg">{question}</span>
        <svg className="w-5 h-5 text-white/40 group-open:rotate-180 transition" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </summary>
      <div className="px-5 pb-5 text-white/60 leading-relaxed">{answer}</div>
    </details>
  );
}

function PhoneMockup({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-3">
      <div className="relative w-40 h-80 rounded-[2rem] border-2 border-white/15 bg-zinc-900 shadow-xl overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-20 h-5 bg-zinc-900 rounded-b-xl z-10" />
        <div className="absolute inset-1 rounded-[1.5rem] overflow-hidden bg-black">
          {children}
        </div>
      </div>
      <span className="text-sm text-white/50 font-medium">{label}</span>
    </div>
  );
}
