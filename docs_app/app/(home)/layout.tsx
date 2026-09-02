/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { HomeLayout } from "fumadocs-ui/layouts/home"
import { baseOptions } from "@/lib/layout.shared"

export default function Layout({ children }: LayoutProps<"/">) {
  const options = baseOptions()

  return (
    // No search box on the landing page: it searches the docs, and the docs
    // pages have it in the same spot.
    <HomeLayout {...options} nav={{ ...options.nav, transparentMode: "top" }} searchToggle={{ enabled: false }}>
      {children}
    </HomeLayout>
  )
}
