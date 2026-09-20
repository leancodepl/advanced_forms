/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
"use client"

import { buttonVariants } from "fumadocs-ui/components/ui/button"
import { Check, Clipboard } from "lucide-react"
import { useEffect, useState } from "react"
import { cn } from "@/lib/cn"

/** Copies [text] to the clipboard and says so for a moment. */
export function CopySkillButton({ text, className }: { text: string; className?: string }) {
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    if (!copied) return
    const timer = setTimeout(() => setCopied(false), 2000)
    return () => clearTimeout(timer)
  }, [copied])

  return (
    <button
      type="button"
      className={cn(buttonVariants({ variant: "primary" }), "gap-2 px-4 py-2.5 text-sm", className)}
      onClick={() => {
        navigator.clipboard.writeText(text).then(
          () => setCopied(true),
          () => undefined,
        )
      }}>
      {copied ? <Check className="size-4" aria-hidden /> : <Clipboard className="size-4" aria-hidden />}
      {copied ? "Copied" : "Copy SKILL.md"}
    </button>
  )
}
