/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import Link from "fumadocs-core/link"
import { ArrowRight } from "lucide-react"
import type { ReactNode } from "react"
import { CopyButton } from "./copy-button"
import { ExternalLink, GithubIcon } from "./section"
import { docsRoute, urls } from "@/lib/shared"

const installCommand = "flutter pub add advanced_forms"

export function Hero({ version, demo }: { version: string; demo: ReactNode }) {
  return (
    <section id="top" className="af-hero" aria-labelledby="hero-heading">
      <div className="af-hero-bg" aria-hidden="true" />
      <div className="af-container af-hero-grid">
        <div>
          <p className="af-hero-badges">
            <ExternalLink href={urls.pub} className="af-pill af-pill-accent">
              v{version}
            </ExternalLink>
            <span className="af-pill">Flutter 3.19+</span>
            <span className="af-pill">Apache-2.0</span>
            <span className="af-pill">No codegen</span>
          </p>
          <h1 id="hero-heading">
            Form validation for <span className="af-accent">Flutter</span>, without a framework on top.
          </h1>
          <p className="af-hero-lead">
            Typed field controllers, composable sync and async validation, and form-level state — built on{" "}
            <code>ChangeNotifier</code> and <code>ValueListenable</code>, the primitives your app already uses.
          </p>
          <div className="af-install">
            <div className="af-install-command">
              <span className="af-prompt" aria-hidden="true">
                $
              </span>
              <code>{installCommand}</code>
              <CopyButton text={installCommand} />
            </div>
            <p className="af-install-alt">
              Coming from <code>leancode_forms</code> 0.1.x?{" "}
              <ExternalLink href={urls.migration}>Read the migration guide</ExternalLink>.
            </p>
          </div>
          <div className="af-hero-actions">
            <Link href={`${docsRoute}/first-form`} className="af-button af-button-primary">
              Build your first form
              <ArrowRight />
            </Link>
            <ExternalLink href={urls.repo} className="af-button af-button-secondary">
              <GithubIcon />
              GitHub
            </ExternalLink>
          </div>
        </div>
        <div className="af-hero-demo">{demo}</div>
      </div>
    </section>
  )
}
