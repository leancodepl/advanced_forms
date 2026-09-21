/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import { CodeBlock, Pre } from "fumadocs-ui/components/codeblock"
import { ExternalLink, FileText, Terminal } from "lucide-react"
import type { ReactNode } from "react"
import { CopySkillButton } from "./copy-skill-button"
import { readSkill } from "@/lib/skill"
import { skillRoute, urls } from "@/lib/shared"

/**
 * The one-click way to get the skill: a button that puts the whole
 * `SKILL.md` on the clipboard, next to what the file is and where else it
 * lives. The install steps around it live in `docs/agent-skill.mdx`.
 */
export function SkillCopy() {
  const skill = readSkill()

  return (
    <div className="not-prose bg-fd-card my-4 flex flex-wrap items-center gap-x-6 gap-y-4 rounded-xl border p-4 sm:p-5">
      <div className="flex min-w-0 flex-1 items-center gap-3">
        <FileText className="text-fd-muted-foreground size-8 shrink-0" strokeWidth={1.5} aria-hidden />
        <div className="min-w-0">
          <p className="font-mono text-sm font-semibold">SKILL.md</p>
          <p className="text-fd-muted-foreground text-sm">
            {skill.lines} lines · {skill.size} ·{" "}
            <a href={skillRoute} className="hover:text-fd-foreground underline underline-offset-4">
              raw
            </a>{" "}
            ·{" "}
            <a
              href={urls.skill}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-fd-foreground inline-flex items-center gap-1 underline underline-offset-4">
              GitHub
              <ExternalLink className="size-3" aria-hidden />
            </a>
          </p>
        </div>
      </div>
      <CopySkillButton text={skill.text} />
    </div>
  )
}

/**
 * The whole skill, readable and copyable on the page. Plain text rather than
 * highlighted Markdown: at 40 KB, Shiki's output would weigh more than the
 * rest of the page, and the copy button in the header is the point.
 */
export function SkillSource() {
  const skill = readSkill()

  return (
    <CodeBlock title="SKILL.md" icon={<FileText className="size-3.5" />}>
      <Pre>
        <code>{skill.text}</code>
      </Pre>
    </CodeBlock>
  )
}

/**
 * The title over the install steps. A quiet accent — a soft tint and a rule
 * in the accent colour — so the one-command path reads as the main road
 * without shouting over the copy card above it.
 */
export function SkillBanner({ children }: { children: ReactNode }) {
  return (
    <div
      className="not-prose text-fd-foreground mt-12 mb-6 flex items-center gap-4 rounded-r-xl px-5 py-4"
      style={{ background: "var(--af-accent-soft)", borderLeft: "4px solid var(--af-accent)" }}>
      <Terminal className="size-6 shrink-0" style={{ color: "var(--af-accent-text)" }} aria-hidden />
      <h2 className="m-0 text-xl font-semibold tracking-tight sm:text-2xl">{children}</h2>
    </div>
  )
}
