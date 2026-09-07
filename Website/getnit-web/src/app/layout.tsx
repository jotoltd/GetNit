import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "GetNit — Clean up your photo gallery with a swipe",
  description:
    "GetNit is the fastest way to declutter your iPhone photo gallery. Swipe right to keep, left to delete. Like Tinder, but for your photos.",
  keywords: ["photo cleaner", "gallery cleaner", "iOS app", "delete photos", "photo organizer", "swipe to delete"],
  openGraph: {
    title: "GetNit — Clean up your photo gallery with a swipe",
    description: "Swipe right to keep, left to delete. The fastest way to declutter your iPhone photos.",
    type: "website",
  },
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-black text-white">{children}</body>
    </html>
  );
}
