/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { readSkill } from "@/lib/skill"

export const revalidate = false

/** `SKILL.md`, raw: `curl -fsSL https://advanced-forms.leancode.co/skill.md`. */
export function GET() {
  return new Response(readSkill().text, {
    headers: {
      "Content-Type": "text/markdown; charset=utf-8",
      "Content-Disposition": 'inline; filename="SKILL.md"',
    },
  })
}
