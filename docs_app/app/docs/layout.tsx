/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { source } from "@/lib/source"
import { DocsLayout } from "fumadocs-ui/layouts/notebook"
import { baseOptions } from "@/lib/layout.shared"

export default function Layout({ children }: LayoutProps<"/docs">) {
  const options = baseOptions()

  return (
    <DocsLayout
      tree={source.getPageTree()}
      tabs={false}
      {...options}
      nav={{ ...options.nav, mode: "top" }}
      sidebar={{ defaultOpenLevel: 1 }}>
      {children}
    </DocsLayout>
  )
}
