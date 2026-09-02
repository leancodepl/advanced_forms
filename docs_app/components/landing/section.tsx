/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import type { ReactNode } from "react"
import { cn } from "@/lib/cn"

interface SectionProps {
  id: string
  eyebrow: string
  heading: ReactNode
  lead?: ReactNode
  center?: boolean
  className?: string
  children: ReactNode
}

/**
 * A landing-page section with the shared eyebrow / heading / lead header.
 * Every section is labelled by its heading, so the outline reads well for
 * crawlers and screen readers alike.
 */
export function Section({ id, eyebrow, heading, lead, center, className, children }: SectionProps) {
  const headingId = `${id}-heading`

  return (
    <section id={id} className={cn("af-section", className)} aria-labelledby={headingId}>
      <div className="af-container">
        <header className={cn("af-section-head", center && "af-center")}>
          <p className="af-eyebrow">{eyebrow}</p>
          <h2 id={headingId}>{heading}</h2>
          {lead && <p className="af-lead">{lead}</p>}
        </header>
        {children}
      </div>
    </section>
  )
}

/** An external link that opens in a new tab with the right `rel`. */
export function ExternalLink({
  href,
  className,
  children,
  ...props
}: React.AnchorHTMLAttributes<HTMLAnchorElement> & { href: string }) {
  return (
    <a href={href} className={className} target="_blank" rel="noopener noreferrer" {...props}>
      {children}
    </a>
  )
}

/** Lucide dropped brand icons, so the GitHub mark is drawn here. */
export function GithubIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.75"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...props}>
      <path d="M12 2a10 10 0 0 0-3.16 19.49c.5.09.68-.22.68-.48v-1.7c-2.78.6-3.37-1.34-3.37-1.34-.45-1.15-1.11-1.46-1.11-1.46-.91-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.9 1.53 2.34 1.09 2.91.83.09-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.45-1.27.1-2.64 0 0 .84-.27 2.75 1.02a9.6 9.6 0 0 1 5 0c1.91-1.29 2.75-1.02 2.75-1.02.55 1.37.2 2.39.1 2.64.64.7 1.03 1.59 1.03 2.68 0 3.84-2.34 4.68-4.57 4.93.36.31.68.92.68 1.85v2.74c0 .27.18.58.69.48A10 10 0 0 0 12 2z" />
    </svg>
  )
}
