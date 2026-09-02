/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import Link from "fumadocs-core/link"
import { Keyboard, LogOut, Send } from "lucide-react"
import type { ReactNode } from "react"
import { docsRoute } from "@/lib/shared"

const rules: { title: string; body: ReactNode }[] = [
  {
    title: "The mode decides what triggers a field.",
    body: (
      <>
        Set <code>ValidationMode</code> once on the form and it reaches every field and subform. A field or a subform
        can opt out with a mode of its own.
      </>
    ),
  },
  {
    title: "Sync first, async only if sync passed.",
    body: (
      <>
        A round never asks the server about a value the sync validator already rejected. One round per field at a time;
        a newer value replaces the round in flight.
      </>
    ),
  },
  {
    title: "Untouched fields stay quiet.",
    body: (
      <>
        A field the user has never edited validates nothing on its own, in every mode. <code>validate()</code> is what
        checks those — so a prefilled form never greets the user with errors.
      </>
    ),
  },
]

const modes = [
  {
    icon: Send,
    name: "manual",
    tag: "default",
    when: "Validates on submit.",
    body: "Nothing shouts while the user fills the form in. After the first submit, an edit clears the error that described the old value.",
  },
  {
    icon: Keyboard,
    name: "onUserInteraction",
    tag: "live",
    when: "Validates on every keystroke.",
    body: "Immediate feedback on the field being edited. Async checks wait out their debounce, so typing runs one request, not ten.",
  },
  {
    icon: LogOut,
    name: "onUnfocus",
    tag: "on leave",
    when: "Validates when a field loses focus.",
    body: "The user finishes a field, moves on, and sees the verdict. Tabbing through a field they never touched costs nothing.",
  },
]

/** The three rules and the three modes — the whole trigger behaviour on one screen. */
export function Rules() {
  return (
    <>
      <ol className="af-rules">
        {rules.map(rule => (
          <li key={rule.title} className="af-rule">
            <h3>{rule.title}</h3>
            <p>{rule.body}</p>
          </li>
        ))}
      </ol>

      <ul className="af-feature-grid" style={{ marginTop: "2.5rem" }}>
        {modes.map(mode => (
          <li key={mode.name} className="af-card af-mode">
            <div className="af-mode-head">
              <span className="af-feature-icon">
                <mode.icon aria-hidden="true" />
              </span>
              <span className="af-pill af-pill-accent">{mode.tag}</span>
            </div>
            <h3>
              <code>{mode.name}</code>
            </h3>
            <p className="af-mode-when">{mode.when}</p>
            <p>{mode.body}</p>
          </li>
        ))}
      </ul>
      <p className="af-section-more">
        <Link href={`${docsRoute}/validation/modes`}>Every mode and every event, explained →</Link>
      </p>
    </>
  )
}
