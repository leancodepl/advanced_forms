/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
"use client"

import Link from "fumadocs-core/link"
import { Check, Copy } from "lucide-react"
import { Children, isValidElement, useEffect, useRef, useState, type ReactElement, type ReactNode } from "react"
import { FlutterIsland, type IslandStatus } from "./flutter-island"
import { docsRoute } from "@/lib/shared"

export type CodeMode = "open" | "collapsed" | "hidden"
export type ExampleLayout = "stacked" | "split"

interface ExampleFrameProps {
  exampleId: string
  /** False when the manifest does not know the id — a stale bundle. */
  compiled: boolean
  preview: string
  title?: string
  height?: number
  isolate: boolean
  code: CodeMode
  layout: ExampleLayout
  /** How many Dart fences the example is made of. */
  files: number
  /** Docs-only `Docs*` widgets the snippet uses. */
  helpers: string[]
  caption?: string
  children: ReactNode
}

const statusLabels: Record<IslandStatus, string> = {
  waiting: "idle",
  attaching: "starting",
  ready: "live · try it",
  evicted: "paused",
  failed: "offline",
}

/**
 * The window around a live example: a title bar with the island's status, the
 * running Flutter view, and the source that produced it — one file at a time
 * when the example is split across several fences.
 */
export function ExampleFrame({
  exampleId,
  compiled,
  preview,
  title,
  height,
  isolate,
  code,
  layout,
  files,
  helpers,
  caption,
  children,
}: ExampleFrameProps) {
  const [status, setStatus] = useState<IslandStatus>("waiting")

  const stage = compiled ? (
    isolate ? (
      <iframe
        src={`/flutter-examples/index.html?example=${exampleId}`}
        title={`Live example: ${preview}`}
        loading="lazy"
        className="block w-full"
        style={{ height: height ?? 420 }}
      />
    ) : (
      <FlutterIsland exampleId={exampleId} preview={preview} height={height} onStatusChange={setStatus} />
    )
  ) : (
    <div className="p-4 text-xs text-fd-muted-foreground">
      This example has not been compiled yet. Run <code>npm run examples:build</code> to see it running.
    </div>
  )

  return (
    <figure className="af-example not-prose" data-layout={layout}>
      <div className="af-example-bar">
        <span className="af-dots" aria-hidden="true">
          <span />
          <span />
          <span />
        </span>
        <span className="af-example-title">{title ?? `${preview} · live example`}</span>
        <span className="af-example-status" data-status={isolate ? "ready" : status} aria-live="polite">
          {isolate ? "live · try it" : statusLabels[status]}
        </span>
      </div>

      <div className="af-example-body">
        <div className="af-example-stage" data-settled={status === "ready" || isolate || !compiled}>
          {stage}
        </div>

        {code !== "hidden" && (
          <details className="af-example-source" open={code === "open"}>
            <summary>
              Source
              {files > 0 && (
                <span className="af-example-files">
                  {files} {files === 1 ? "file" : "files"}
                </span>
              )}
            </summary>
            <SourceTabs>{children}</SourceTabs>
          </details>
        )}
      </div>

      {(caption || (helpers.length > 0 && code !== "hidden")) && (
        <figcaption className="af-example-caption">
          {caption && <span>{caption}</span>}
          {helpers.length > 0 && code !== "hidden" && (
            <span>
              {helpers.map((name, index) => (
                <span key={name}>
                  {index > 0 && (index === helpers.length - 1 ? " and " : ", ")}
                  <code>{name}</code>
                </span>
              ))}
              {helpers.length === 1 ? " is a shorthand" : " are shorthands"} these docs define, not part of the package.
              See <Link href={`${docsRoute}/rendering`}>Rendering fields</Link> for the widget code an app writes.
            </span>
          )}
        </figcaption>
      )}
    </figure>
  )
}

/**
 * The fences of an example, one at a time behind a tab per file. A single
 * fence is rendered as it is. The fences arrive already highlighted, as the
 * `<figure>` elements Fumadocs renders for a code block, with the fence's
 * `title` still on their props — that is what labels the tabs.
 */
function SourceTabs({ children }: { children: ReactNode }) {
  const fences = Children.toArray(children).filter(isValidElement) as ReactElement<{ title?: string }>[]
  const [active, setActive] = useState(0)
  const [copied, setCopied] = useState(false)
  const panelRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!copied) return
    const timer = setTimeout(() => setCopied(false), 2000)
    return () => clearTimeout(timer)
  }, [copied])

  if (fences.length < 2) {
    return <div className="af-example-code">{children}</div>
  }

  const current = fences[Math.min(active, fences.length - 1)]

  function copy() {
    const pre = panelRef.current?.querySelector("pre")
    if (!pre) return
    navigator.clipboard.writeText(pre.textContent ?? "").then(
      () => setCopied(true),
      () => undefined,
    )
  }

  return (
    <div className="af-example-code" data-tabs="true">
      <div className="af-example-tabs" role="tablist" aria-label="Source files">
        {fences.map((fence, index) => (
          <button
            key={fence.key ?? index}
            type="button"
            role="tab"
            aria-selected={index === active}
            className="af-example-tab"
            onClick={() => setActive(index)}>
            {fence.props.title ?? `file ${index + 1}`}
          </button>
        ))}
        <button
          type="button"
          className="af-example-copy"
          onClick={copy}
          aria-label={copied ? "Copied" : "Copy this file"}
          data-copied={copied}>
          {copied ? <Check /> : <Copy />}
        </button>
      </div>
      <div ref={panelRef} role="tabpanel">
        {current}
      </div>
    </div>
  )
}
