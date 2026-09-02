/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import Link from "fumadocs-core/link"
import { BookOpen, ExternalLink as ExternalIcon } from "lucide-react"
import { ExternalLink } from "./section"
import { Logo } from "@/components/logo"
import { docsRoute, urls } from "@/lib/shared"

export function SiteFooter({ version }: { version: string }) {
  return (
    <footer className="af-footer">
      <section className="af-cta" aria-labelledby="cta-heading">
        <div className="af-container af-cta-inner">
          <h2 id="cta-heading">Ready to type your first field?</h2>
          <p>One dependency, one import, and a form that tells you when it can be submitted.</p>
          <div className="af-hero-actions af-center">
            <ExternalLink href={urls.pub} className="af-button af-button-primary">
              Get it on pub.dev
              <ExternalIcon />
            </ExternalLink>
            <Link href={`${docsRoute}/first-form`} className="af-button af-button-secondary">
              <BookOpen />
              Read the docs
            </Link>
          </div>
        </div>
      </section>

      <div className="af-container af-footer-grid">
        <div className="af-footer-brand">
          <Logo />
          <p>
            Form validation and state management for Flutter.{" "}
            <ExternalLink href={urls.changelog}>v{version}</ExternalLink>, Apache-2.0.
          </p>
        </div>
        <nav aria-label="Project">
          <h3>Project</h3>
          <ul>
            <li>
              <ExternalLink href={urls.pub}>pub.dev</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.repo}>GitHub</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.changelog}>Changelog</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.issues}>Issues</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.apiReference}>API reference</ExternalLink>
            </li>
          </ul>
        </nav>
        <nav aria-label="Docs">
          <h3>Docs</h3>
          <ul>
            <li>
              <Link href={`${docsRoute}/installation`}>Installation</Link>
            </li>
            <li>
              <Link href={`${docsRoute}/first-form`}>Your first form</Link>
            </li>
            <li>
              <Link href={`${docsRoute}/validation-modes`}>Validation modes</Link>
            </li>
            <li>
              <Link href={`${docsRoute}/async-validation`}>Async validation</Link>
            </li>
            <li>
              <Link href={`${docsRoute}/faq`}>FAQ</Link>
            </li>
          </ul>
        </nav>
        <nav aria-label="LeanCode">
          <h3>LeanCode</h3>
          <ul>
            <li>
              <ExternalLink href={urls.leancode}>leancode.co</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.patrol}>Patrol</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.leancodePackages}>More packages</ExternalLink>
            </li>
            <li>
              <ExternalLink href={urls.leancodeEstimate}>Hire our team</ExternalLink>
            </li>
          </ul>
        </nav>
      </div>

      <div className="af-container af-footer-bottom">
        <p>
          © {new Date().getFullYear()} <ExternalLink href={urls.leancode}>LeanCode</ExternalLink>. Apache License 2.0.
        </p>
        <p>
          Built with <ExternalLink href="https://fumadocs.dev">Fumadocs</ExternalLink>. The examples on this site run in
          Flutter, in your browser.
        </p>
      </div>
    </footer>
  )
}
