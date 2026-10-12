/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { Terminal } from "lucide-react"
import type { ReactNode } from "react"

/**
 * The title over the install steps. A quiet accent — a soft tint and a rule
 * in the accent colour — so the one-command path reads as the main road.
 */
export function SkillBanner({ children }: { children: ReactNode }) {
  return (
    <div
      className="not-prose text-fd-foreground mt-12 mb-6 flex items-center gap-4 rounded-r-xl px-5 py-4"
      style={{ background: "var(--af-accent-soft)", borderLeft: "4px solid var(--af-accent)" }}>
      <Terminal className="size-6 shrink-0" style={{ color: "var(--af-accent-text)" }} aria-hidden />
      {/* The docs' heading rules add a top margin and padding to every h2; this one sits in a box. */}
      <h2 className="text-xl font-semibold tracking-tight sm:text-2xl" style={{ margin: 0, padding: 0 }}>
        {children}
      </h2>
    </div>
  )
}
