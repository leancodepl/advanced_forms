/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import Link from "fumadocs-core/link"
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

type Cell = "yes" | "sync" | "no"

const gate: { mode: string; valueChanged: Cell; unfocus: Cell; dependency: Cell }[] = [
  { mode: "manual", valueChanged: "no", unfocus: "no", dependency: "no" },
  { mode: "onUserInteraction", valueChanged: "yes", unfocus: "no", dependency: "sync" },
  { mode: "onUnfocus", valueChanged: "no", unfocus: "yes", dependency: "sync" },
]

function Mark({ cell }: { cell: Cell }) {
  switch (cell) {
    case "yes":
      return (
        <span className="af-mark af-mark-yes" aria-label="validates">
          ✓ validates
        </span>
      )
    case "sync":
      return (
        <span className="af-mark af-mark-partial" aria-label="sync validator only">
          sync only
        </span>
      )
    case "no":
      return (
        <span className="af-mark af-mark-no" aria-label="nothing">
          —
        </span>
      )
  }
}

/** The three rules and the gate table — the whole trigger behaviour on one screen. */
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

      <div className="af-table-wrap" style={{ marginTop: "2.5rem" }}>
        <table className="af-table">
          <thead>
            <tr>
              <th scope="col">Mode</th>
              <th scope="col">Value changed</th>
              <th scope="col">Focus left</th>
              <th scope="col">A dependency changed</th>
            </tr>
          </thead>
          <tbody>
            {gate.map(row => (
              <tr key={row.mode}>
                <th scope="row">
                  <code>{row.mode}</code>
                </th>
                <td>
                  <Mark cell={row.valueChanged} />
                </td>
                <td>
                  <Mark cell={row.unfocus} />
                </td>
                <td>
                  <Mark cell={row.dependency} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="af-section-more">
        <Link href={`${docsRoute}/validation/modes`}>Every cell of that table, explained →</Link>
      </p>
    </>
  )
}
