/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import {
  Braces,
  Combine,
  Gauge,
  GitFork,
  Layers,
  ListChecks,
  Lock,
  MousePointerClick,
  Server,
  type LucideIcon,
} from "lucide-react"
import type { ReactNode } from "react"
import { Section } from "./section"

interface Feature {
  icon: LucideIcon
  title: string
  body: ReactNode
}

const features: Feature[] = [
  {
    icon: Braces,
    title: "Typed field controllers",
    body: (
      <>
        Text, boolean, single-select and multi-select fields, each with its own value type <em>and</em> its own error
        type. Plain strings to start, an enum or a sealed class when the form grows.
      </>
    ),
  },
  {
    icon: Combine,
    title: "Validators that compose",
    body: (
      <>
        <code>filled</code>, <code>atLeastLength</code>, <code>notNull</code>, <code>mustBeTrue</code> and the numeric
        checks, combined with <code>&amp;</code> and <code>|</code> — or any <code>E? Function(T)</code> you write
        yourself.
      </>
    ),
  },
  {
    icon: Server,
    title: "Async validation done right",
    body: (
      <>
        Debounced server checks with a timeout, cancellation of stale rounds, a cached verdict while the value stands,
        and a failure model that never leaves a field stuck on “validating”.
      </>
    ),
  },
  {
    icon: MousePointerClick,
    title: "Three validation modes",
    body: (
      <>
        Validate on submit, on every keystroke, or when a field loses focus. Set once on the form; a field or a subform
        can opt out with its own mode.
      </>
    ),
  },
  {
    icon: GitFork,
    title: "Cross-field logic",
    body: (
      <>
        <code>subscribeToFields</code> re-runs a rule when its dependencies change; <code>addRelation</code> derives one
        field’s value from another. Repeat-password and running totals in two lines each.
      </>
    ),
  },
  {
    icon: Layers,
    title: "Subforms",
    body: (
      <>
        Attach and detach nested controllers. Their fields join the parent’s <code>validate</code>, reset, read-only and
        error handling — one subform per wizard step, or one per row of a dynamic list.
      </>
    ),
  },
  {
    icon: ListChecks,
    title: "Form-level state",
    body: (
      <>
        <code>canSubmit</code>, <code>wasModified</code>, <code>validating</code> and <code>validationErrors</code>,
        derived from the live tree on every read and ready to bind to a submit button.
      </>
    ),
  },
  {
    icon: Lock,
    title: "Read-only fields and server errors",
    body: (
      <>
        Freeze a value with <code>markReadOnly</code>, push a 422 response in with <code>setError</code>, and let the
        next edit clear it — no bookkeeping.
      </>
    ),
  },
  {
    icon: Gauge,
    title: "Granular rebuilds",
    body: (
      <>
        One builder per field. A keystroke rebuilds that field’s subtree and nothing else, and a no-op write notifies
        nobody because state is value-equal.
      </>
    ),
  },
]

export function Features() {
  return (
    <Section
      id="features"
      eyebrow="Everything a form needs"
      heading="Small enough to read. Complete enough to ship."
      lead={
        <>
          About two thousand lines of Dart, three runtime dependencies, and no build step. Every behaviour below is
          pinned by the package’s test suite and shown running in the docs.
        </>
      }>
      <ul className="af-feature-grid">
        {features.map(feature => (
          <li key={feature.title} className="af-card af-feature">
            <span className="af-feature-icon">
              <feature.icon aria-hidden="true" />
            </span>
            <h3>{feature.title}</h3>
            <p>{feature.body}</p>
          </li>
        ))}
      </ul>
    </Section>
  )
}
