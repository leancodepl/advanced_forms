/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import logoDark from "@/public/logo-dark.svg"
import logoLight from "@/public/logo-light.svg"
import { appName } from "@/lib/shared"
import { cn } from "@/lib/cn"

/**
 * The word mark, as designed: `public/logo-light.svg` on the light theme and
 * `public/logo-dark.svg` on the dark one. Both are in the DOM and the theme
 * classes decide which one is visible, so a theme switch never flashes. The
 * files are imported rather than referenced by path, so their URL carries a
 * content hash and a redesigned logo is never stuck behind a browser cache.
 */
export function Logo({ large = false, className }: { large?: boolean; className?: string }) {
  return (
    <span className={cn("af-logo", large && "af-logo-large", className)}>
      <img src={logoLight.src} alt={appName} className="theme-diagram-light" />
      <img src={logoDark.src} alt={appName} className="theme-diagram-dark" />
    </span>
  )
}

/**
 * The mark alone, squared: the chevron and the bars on a rounded black tile.
 * Also what `app/icon.svg` is; keep the two in step.
 */
export function LogoMark({ size = 56 }: { size?: number }) {
  return (
    <svg viewBox="109 4 364 364" height={size} width={size} fill="none" aria-hidden="true">
      <rect x="109" y="4" width="364" height="364" rx="72" fill="black" />
      <path
        d="M173 244.296L239.253 128.587L304.748 244.296"
        stroke="white"
        strokeWidth="37.8058"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M304.748 128.587H409"
        stroke="#F9FF07"
        strokeWidth="37.8058"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M336.825 185.869L409 185.869"
        stroke="#F9FF07"
        strokeWidth="37.8058"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}
