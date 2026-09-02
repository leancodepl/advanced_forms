/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import Link from "fumadocs-core/link"
import { ArrowRight, Bot } from "lucide-react"
import { Features } from "@/components/landing/features"
import { SiteFooter } from "@/components/landing/footer"
import { Hero } from "@/components/landing/hero"
import { LandingMdx } from "@/components/landing/landing-mdx"
import { Rules } from "@/components/landing/rules"
import { ExternalLink, Section } from "@/components/landing/section"
import { docsRoute, urls } from "@/lib/shared"
import { packageVersion } from "@/lib/version"

export default function HomePage() {
  const version = packageVersion()

  return (
    <main className="af-landing">
      <Hero version={version} demo={<LandingMdx file="hero.mdx" />} />

      <Section
        id="model"
        eyebrow="The model"
        heading="A controller holds the fields. A widget binds to each one."
        lead={
          <>
            No <code>Form</code> widget, no <code>GlobalKey</code>, no <code>TextEditingController</code> plumbing. The
            controller below is the whole form; the widgets only render it. It is running on the right — submit it
            empty.
          </>
        }>
        <LandingMdx file="signup.mdx" />
        <ul className="af-checklist" style={{ marginTop: "2rem", maxWidth: "52rem" }}>
          <li>
            <strong>
              One call to <code>registerFields</code>
            </strong>{" "}
            and the form owns the fields: it disposes them, tracks <code>wasModified</code>, and reaches them in{" "}
            <code>validate</code>, <code>resetAll</code> and every other broadcast.
          </li>
          <li>
            <strong>
              The field owns its <code>TextEditingController</code> and <code>FocusNode</code>.
            </strong>{" "}
            Bind the widget to <code>field.textController</code> and programmatic writes — <code>reset</code>,{" "}
            <code>prefill</code>, a relation — show up on screen.
          </li>
          <li>
            <strong>Errors are your type.</strong> <code>E</code> is whatever you choose: a string, an enum, a sealed
            class. The package never formats a message.
          </li>
        </ul>
      </Section>

      <Section
        id="validation"
        eyebrow="Three rules"
        heading="Validation you can predict."
        lead={
          <>
            The trigger behaviour is twenty lines of Dart and one table. Switch the mode below while you type to see
            each row of it.
          </>
        }>
        <Rules />
        <div style={{ marginTop: "2.5rem" }}>
          <LandingMdx file="modes.mdx" />
        </div>
      </Section>

      <Section
        id="async"
        eyebrow="Server-side checks"
        heading="Async validation without the races."
        lead={
          <>
            “Is this username taken?” is one <code>AsyncValidation</code>. Debounce, cancellation, timeout and failure
            handling come with it — try <code>alice</code>, then <code>boom</code>.
          </>
        }>
        <LandingMdx file="async.mdx" />
        <ul className="af-checklist" style={{ marginTop: "2rem", maxWidth: "52rem" }}>
          <li>
            <strong>Debounced while typing, immediate on submit.</strong> <code>await validate()</code> flushes a
            waiting check rather than reporting the field bad for being busy.
          </li>
          <li>
            <strong>A stale answer can never land.</strong> A new value replaces the round in flight; the old result is
            dropped, not applied late.
          </li>
          <li>
            <strong>Verdicts are reused.</strong> A second submit on an unchanged form makes zero network calls.
          </li>
          <li>
            <strong>A failure is not an error.</strong> A validator that throws or times out puts the field on{" "}
            <code>failedValidation</code>: not valid, not stuck, retried by the next submit.
          </li>
        </ul>
        <p className="af-section-more">
          <Link href={`${docsRoute}/validation/async`}>How rounds, verdicts and failures fit together →</Link>
        </p>
      </Section>

      <Features />

      <section className="af-section" aria-labelledby="skill-heading">
        <div className="af-container">
          <div className="af-band">
            <div>
              <p className="af-eyebrow">Agent skill</p>
              <h2 id="skill-heading">Your coding agent already knows this API.</h2>
              <p className="af-lead">
                The repository ships an Agent Skill that teaches Claude Code — or any agent that supports skills — the
                full <code>advanced_forms</code> API, so it generates fields, validation, cross-field logic and subforms
                idiomatically.
              </p>
            </div>
            <div className="af-hero-actions">
              <Link href={`${docsRoute}/agent-skill`} className="af-button af-button-primary">
                <Bot />
                Install the skill
              </Link>
              <ExternalLink href={urls.skill} className="af-button af-button-secondary">
                Read SKILL.md
                <ArrowRight />
              </ExternalLink>
            </div>
          </div>
        </div>
      </section>

      <SiteFooter version={version} />
    </main>
  )
}
