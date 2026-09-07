/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { source } from "@/lib/source"
import { DocsLayout } from "fumadocs-ui/layouts/notebook"
import { baseOptions } from "@/lib/layout.shared"
import { NavTitle } from "@/components/nav-title"

export default function Layout({ children }: LayoutProps<"/docs">) {
  const options = baseOptions()

  return (
    <DocsLayout
      tree={source.getPageTree()}
      tabs={false}
      {...options}
      nav={{ ...options.nav, mode: "top" }}
      // The logo links to the landing page, which lives outside the Next app.
      slots={{ navTitle: NavTitle }}
      sidebar={{ defaultOpenLevel: 1 }}>
      {children}
    </DocsLayout>
  )
}
