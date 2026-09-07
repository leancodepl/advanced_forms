/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { RootProvider } from "fumadocs-ui/provider/next"
import "./global.css"
import { JetBrains_Mono, Space_Grotesk } from "next/font/google"
import type { Metadata } from "next"
import { appName, description, tagline } from "@/lib/shared"

const sans = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-space-grotesk",
  display: "swap",
})

const mono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains-mono",
  display: "swap",
})

export const metadata: Metadata = {
  metadataBase: new URL(
    process.env.VERCEL_PROJECT_PRODUCTION_URL
      ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
      : "http://localhost:3000",
  ),
  title: {
    template: `%s — ${appName}`,
    default: `${appName} — ${tagline}`,
  },
  description,
}

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    // `data-scroll-behavior`: global.css sets `scroll-behavior: smooth`, and Next
    // only switches it off for the scroll-to-top of a route change when told
    // so; otherwise the animated scroll lands a little below the top.
    <html
      lang="en"
      className={`${sans.variable} ${mono.variable}`}
      data-scroll-behavior="smooth"
      suppressHydrationWarning>
      <body className="flex flex-col min-h-screen">
        <RootProvider theme={{ defaultTheme: "dark" }}>{children}</RootProvider>
      </body>
    </html>
  )
}
