# GetNit

Clean up your iPhone photo gallery with a swipe. Like Tinder, but for your photos.

## Structure

- **`iOS App/`** — Native SwiftUI iOS app (iOS 17+)
- **`Website/`** — Marketing website (Next.js + Tailwind CSS)

## iOS App

A SwiftUI app that lets you swipe through your photo gallery:
- Swipe right to keep, left to mark for deletion
- Review all marked photos before batch-deleting
- Undo any swipe, filter by album/screenshots/date, remembers progress
- 100% on-device, no data collection

### Build

```bash
cd "iOS App"
xcodegen generate
open GetNit.xcodeproj
```

Requires Xcode 15+ and iOS 17+ deployment target.

## Website

Marketing landing page built with Next.js 16 and Tailwind CSS 4.

### Development

```bash
cd Website/getnit-web
npm run dev
```

### Deploy

Deployed via Vercel:
```bash
cd Website/getnit-web
vercel
```

## License

All rights reserved.
