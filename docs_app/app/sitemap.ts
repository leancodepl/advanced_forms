/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import type { MetadataRoute } from "next"
import { source } from "@/lib/source"
import { docsRoute, siteUrl } from "@/lib/shared"

/** The landing page, the docs index and every documentation page. */
export default function sitemap(): MetadataRoute.Sitemap {
  const pages = source.getPages().map(page => ({
    url: `${siteUrl}${page.url}`,
    changeFrequency: "weekly" as const,
    priority: page.url === docsRoute ? 0.9 : 0.7,
  }))

  return [{ url: `${siteUrl}/`, changeFrequency: "weekly", priority: 1 }, ...pages]
}
