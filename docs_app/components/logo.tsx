/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { appName } from "@/lib/shared"
import { cn } from "@/lib/cn"

/** The glyph: three form rows, the last one checked off. */
export function LogoMark(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.4"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...props}>
      <path d="M4 6h16" />
      <path d="M4 12h10" />
      <path d="M4 18h6" />
      <path d="m14 17 2.5 2.5L21 15" />
    </svg>
  )
}

/** The word mark: the glyph in a lime tile, next to the package name. */
export function Logo({ large = false, className }: { large?: boolean; className?: string }) {
  return (
    <span className={cn("af-logo", large && "af-logo-large", className)} aria-label={appName}>
      <span className="af-logo-mark">
        <LogoMark />
      </span>
      <span>{appName}</span>
    </span>
  )
}
