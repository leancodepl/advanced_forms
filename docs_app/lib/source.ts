/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { loader } from "fumadocs-core/source"
import { lucideIconsPlugin } from "fumadocs-core/source/lucide-icons"
import { docsContentRoute, docsImageRoute, docsRoute } from "./shared"
import { defineCollections, defineDocs } from "fumadocs-mdx/macro"
import { metaSchema, pageSchema } from "fumadocs-core/source/schema"

const docs = defineDocs({
  dir: "../docs",
  docs: {
    schema: pageSchema,
    postprocess: {
      includeProcessedMarkdown: true,
    },
  },
  meta: {
    schema: metaSchema,
  },
})

/**
 * MDX blocks the landing page embeds — the live demos in the hero and the
 * sections below it. They go through the same pipeline as the docs, so a
 * `<AdvancedFormsExample>` there is compiled into the Flutter bundle too.
 */
export const landing = defineCollections({
  type: "doc",
  dir: "content/landing",
})

// See https://fumadocs.dev/docs/headless/source-api for more info
export const source = loader({
  baseUrl: docsRoute,
  source: docs.toFumadocsSource(),
  plugins: [lucideIconsPlugin()],
})

export function getPageImageUrl(page: (typeof source)["$inferPage"]) {
  const segments = [...page.slugs, "image.png"]

  return {
    segments,
    url: "/" + [page.locale, ...docsImageRoute.split("/"), ...segments].filter(Boolean).join("/"),
  }
}

export function getPageMarkdownUrl(page: (typeof source)["$inferPage"]) {
  const segments = [...page.slugs, "content.md"]

  return {
    segments,
    url: "/" + [page.locale, ...docsContentRoute.split("/"), ...segments].filter(Boolean).join("/"),
  }
}

export async function getLLMText(page: (typeof source)["$inferPage"]) {
  const processed = await page.data.getText("processed")

  return `# ${page.data.title} (${page.url})

${processed}`
}
