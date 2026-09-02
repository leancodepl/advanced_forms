/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
"use client"

import { Check, Copy } from "lucide-react"
import { useEffect, useState } from "react"

/** Copies `text` to the clipboard and says so for a moment. */
export function CopyButton({ text, label = "Copy" }: { text: string; label?: string }) {
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    if (!copied) return
    const timer = setTimeout(() => setCopied(false), 2000)
    return () => clearTimeout(timer)
  }, [copied])

  return (
    <button
      type="button"
      className="af-copy-button"
      data-copied={copied}
      aria-live="polite"
      aria-label="Copy to clipboard"
      onClick={() => {
        navigator.clipboard.writeText(text).then(
          () => setCopied(true),
          () => undefined,
        )
      }}>
      {copied ? <Check /> : <Copy />}
      <span>{copied ? "Copied!" : label}</span>
    </button>
  )
}
