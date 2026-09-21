/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { readFileSync, statSync } from "node:fs"
import path from "node:path"

/**
 * The Agent Skill is one Markdown file in the repo root (`skills/advanced_forms-forms/`),
 * the same one the package ships. Read at build time, like `../docs`, so the
 * site can never serve a stale copy of it.
 */
const skillFile = path.join(process.cwd(), "..", "skills", "advanced_forms-forms", "SKILL.md")

export interface Skill {
  /** The file, verbatim. */
  text: string
  lines: number
  /** Human-readable size, e.g. "41 KB". */
  size: string
}

export function readSkill(): Skill {
  const text = readFileSync(skillFile, "utf8")
  const bytes = statSync(skillFile).size
  return {
    text,
    lines: text.split("\n").length,
    size: `${Math.round(bytes / 1024)} KB`,
  }
}
