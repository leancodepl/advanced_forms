/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { NextRequest, NextResponse } from "next/server"
import { isMarkdownPreferred, rewritePath } from "fumadocs-core/negotiation"
import { docsContentRoute, docsRoute } from "@/lib/shared"

const skipPrefixes = ["/api", "/og", "/llms", "/flutter-examples"]

// `/docs/validation.md`, or `/docs/validation` with `Accept: text/markdown`,
// serve the page's Markdown instead of the HTML.
const { rewrite: rewriteDocs } = rewritePath(`${docsRoute}{/*path}`, `${docsContentRoute}{/*path}/content.md`)
const { rewrite: rewriteSuffix } = rewritePath(`${docsRoute}{/*path}.md`, `${docsContentRoute}{/*path}/content.md`)

function shouldSkip(pathname: string) {
  return skipPrefixes.some(
    prefix => pathname === prefix || pathname.startsWith(`${prefix}/`) || pathname.startsWith(`${prefix}.`),
  )
}

export default function proxy(request: NextRequest) {
  if (shouldSkip(request.nextUrl.pathname)) {
    return NextResponse.next()
  }

  const result = rewriteSuffix(request.nextUrl.pathname)
  if (result) {
    return NextResponse.rewrite(new URL(result, request.nextUrl))
  }

  if (isMarkdownPreferred(request)) {
    const rewritten = rewriteDocs(request.nextUrl.pathname)

    if (rewritten) {
      return NextResponse.rewrite(new URL(rewritten, request.nextUrl), {
        headers: { Vary: "Accept" },
      })
    }
  }

  return NextResponse.next()
}
