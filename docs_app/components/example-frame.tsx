/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
"use client"

import Link from "fumadocs-core/link"
import { useState, type ReactNode } from "react"
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
 * running Flutter view, and the source that produced it.
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
            <div className="af-example-code">{children}</div>
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
