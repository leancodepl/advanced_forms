/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
"use client"

import type { ComponentProps } from "react"
import { Logo } from "@/components/logo"

/**
 * The header logo, as a plain anchor rather than a Next `Link`: `/` is the
 * Jaspr landing page served from `public/index.html`, a document outside the
 * app that client-side navigation cannot reach.
 */
export function NavTitle(props: ComponentProps<"a">) {
  return (
    <a href="/" {...props}>
      <Logo />
    </a>
  )
}
