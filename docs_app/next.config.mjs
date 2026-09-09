/*
 * AI-Provenance:
 *   model: Cursor Grok 4.6
 *   harness: Cursor
 *   skills:
 *     - mark-ai-provenance
 */
import { createMDX } from "fumadocs-mdx/next"
import { fileURLToPath } from "node:url"

const withMDX = createMDX()
const repoRoot = fileURLToPath(new URL("..", import.meta.url))

/** @type {import('next').NextConfig} */
const config = {
  outputFileTracingRoot: repoRoot,
  reactStrictMode: true,
  turbopack: {
    root: repoRoot,
  },
  /**
   * `FLUTTER_EXAMPLES_DEV_SERVER` is the authoring loop for the live examples:
   * point it at `npm run examples:serve` and the islands come from the Flutter
   * dev server instead of the last `examples:build`. It has to be a proxy
   * rather than a direct URL because the debug asset server sends no
   * `Access-Control-Allow-Origin` header, unlike the release one.
   */
  async rewrites() {
    const beforeFiles = [
      // The landing page is a static site built by Jaspr (see ../landing) and
      // copied into public/ by `npm run landing:build`; the docs start at /docs.
      { source: "/", destination: "/index.html" },
    ]

    const devServer = process.env.FLUTTER_EXAMPLES_DEV_SERVER
    if (devServer) {
      beforeFiles.push({ source: "/flutter-examples/:path*", destination: `${devServer}/:path*` })
    }

    return { beforeFiles }
  },
  /**
   * The landing page's fonts (public/fonts, copied from ../landing/web/fonts)
   * have no content hash in their names, so a day of caching with revalidation
   * in the background: a repeat visitor renders in the right face at once.
   */
  async headers() {
    return [
      {
        source: "/fonts/:path*",
        headers: [{ key: "Cache-Control", value: "public, max-age=86400, stale-while-revalidate=604800" }],
      },
    ]
  },
}

export default withMDX(config)
