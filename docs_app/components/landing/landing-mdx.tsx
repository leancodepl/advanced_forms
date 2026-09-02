/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { getMDXComponents } from "@/components/mdx"
import { landing } from "@/lib/source"

/**
 * Renders one block from `content/landing/`. The blocks are MDX so the live
 * examples on the landing page are authored — and compiled — exactly like the
 * ones in the docs.
 */
export function LandingMdx({ file }: { file: string }) {
  const doc = landing.get(file)
  if (!doc) {
    throw new Error(`No landing block at content/landing/${file}.`)
  }

  const Body = doc.body
  return <Body components={getMDXComponents()} />
}
