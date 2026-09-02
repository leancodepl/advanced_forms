/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { defineConfig } from "fumadocs-mdx/config"
import { rehypeCodeDefaultOptions } from "fumadocs-core/mdx-plugins"
import { remarkExampleId } from "./lib/flutter-examples/remark-example-id"

// Global MDX options. The collections themselves live in `lib/source.ts` via
// `fumadocs-mdx/macro`; a collection-level `mdxOptions` would *replace* the
// fumadocs preset (Shiki, GFM, headings, search structure), while the global
// one is merged into it.
export default defineConfig({
  mdxOptions: {
    // Prepended rather than appended: the id has to be stamped on before any
    // other transformer can rewrite the tree the hash is taken from.
    remarkPlugins: plugins => [remarkExampleId, ...plugins],
    rehypeCodeOptions: {
      ...rehypeCodeDefaultOptions,
      // Palenight is the palette the LeanCode design system uses for code —
      // the same token colours as ciach.leancode.co.
      themes: {
        light: "github-light",
        dark: "material-theme-palenight",
      },
    },
  },
})
