/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { appName } from "@/lib/shared"
import { cn } from "@/lib/cn"

/**
 * The word mark, as designed: `public/logo-light.svg` on the light theme and
 * `public/logo-dark.svg` on the dark one. Both are in the DOM and the theme
 * classes decide which one is visible, so a theme switch never flashes.
 */
export function Logo({ large = false, className }: { large?: boolean; className?: string }) {
  return (
    <span className={cn("af-logo", large && "af-logo-large", className)}>
      <img src="/logo-light.svg" alt={appName} className="theme-diagram-light" />
      <img src="/logo-dark.svg" alt={appName} className="theme-diagram-dark" />
    </span>
  )
}

/**
 * The mark alone, squared: the chevron and the bars on a rounded black tile.
 * Also what `app/icon.svg` is; keep the two in step.
 */
export function LogoMark({ size = 56 }: { size?: number }) {
  return (
    <svg viewBox="107.2 50.3 372 372" height={size} width={size} fill="none" aria-hidden="true">
      <rect x="107.2" y="50.3" width="372" height="372" rx="72" fill="black" />
      <rect
        x="266.423"
        y="183.133"
        width="147.277"
        height="42.2665"
        rx="21.1333"
        transform="rotate(120 266.423 183.133)"
        fill="white"
      />
      <rect
        width="142.634"
        height="42.2727"
        rx="21.1364"
        transform="matrix(0.5 0.866025 0.866025 -0.5 209.527 183.354)"
        fill="white"
      />
      <rect x="282.922" y="171.48" width="147.351" height="31.4026" rx="15.7013" fill="#F9FF07" />
      <rect x="317.948" y="221" width="112.325" height="31.4026" rx="15.7013" fill="#F9FF07" />
    </svg>
  )
}
