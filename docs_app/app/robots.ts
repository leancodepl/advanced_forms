/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import type { MetadataRoute } from "next"
import { siteUrl } from "@/lib/shared"

// Vercel adds `X-Robots-Tag: noindex` to preview deployments on its own, so
// this can allow everything: only production is ever indexed.
export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      // The search endpoint is JSON for the docs' search box, not a page.
      disallow: ["/api/"],
    },
    sitemap: `${siteUrl}/sitemap.xml`,
    host: siteUrl,
  }
}
