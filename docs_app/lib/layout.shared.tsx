/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import type { BaseLayoutProps } from "fumadocs-ui/layouts/shared"
import { Package } from "lucide-react"
import { Logo } from "@/components/logo"
import { docsRoute, urls } from "./shared"

/** Header options shared by the landing page and the documentation. */
export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      title: <Logo />,
      url: "/",
    },
    links: [
      {
        text: "Docs",
        url: docsRoute,
        active: "nested-url",
      },
      {
        text: "Examples",
        url: `${docsRoute}/example-app`,
        active: "url",
      },
      {
        type: "icon",
        text: "pub.dev",
        label: "advanced_forms on pub.dev",
        url: urls.pub,
        icon: <Package />,
        external: true,
      },
    ],
    githubUrl: urls.repo,
  }
}
