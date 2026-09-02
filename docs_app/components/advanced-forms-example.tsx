/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 */
import type { ReactNode } from "react"
import { ExampleFrame, type CodeMode, type ExampleLayout } from "./example-frame"
import { flutterExamples } from "@/lib/flutter-examples/manifest.generated"

interface AdvancedFormsExampleProps {
  /**
   * Content hash of the Dart fences, stamped on by the `remarkExampleId`
   * plugin. Authors never write it.
   */
  id?: string
  /** Widget to mount. Defaults to the first widget class in the snippet. */
  preview?: string
  /** Shown in the frame's title bar. Defaults to the preview widget's name. */
  title?: string
  /** Fixed island height. Needed for `Scaffold` and for scrolling demos. */
  height?: number | string
  /** Render in an iframe instead of a shared view. Escape hatch; needs `height`. */
  isolate?: boolean
  /**
   * How the source is shown under the running example: expanded, behind a
   * "Source" toggle, or not at all (the landing page's hero).
   */
  code?: CodeMode
  /**
   * `stacked` puts the code under the running example; `split` puts them side
   * by side, for the wide sections of the landing page.
   */
  layout?: ExampleLayout
  caption?: string
  /** The highlighted code fences, rendered under the island. */
  children: ReactNode
}

/**
 * A docs example that is both listing and demo: the Dart fences inside it are
 * compiled into the Flutter bundle at build time and rendered above the code
 * that produced them.
 *
 *     <AdvancedFormsExample preview="SignupForm">
 *
 *     ```dart title="signup_form.dart"
 *     class SignupForm extends StatefulWidget { ... }
 *     ```
 *
 *     </AdvancedFormsExample>
 *
 * An auto-height island must not use `Scaffold`, which takes all the height it
 * is offered; pass `height` for those.
 */
export function AdvancedFormsExample({
  id,
  title,
  height,
  isolate,
  code = "open",
  layout = "stacked",
  caption,
  children,
}: AdvancedFormsExampleProps) {
  if (!id) {
    throw new Error(
      "<AdvancedFormsExample> was rendered without an id. The remarkExampleId plugin in " +
        "source.config.ts is what adds it — check that the docs are built through it.",
    )
  }

  const example = flutterExamples[id]

  // A missing id means the manifest was generated from different MDX than this
  // build is rendering. Failing the build beats shipping a page with a hole in
  // it; in development it is usually just a forgotten `examples:generate`.
  if (!example) {
    const message =
      `No compiled example for id "${id}". Run \`npm run examples:generate\` — ` +
      "the docs and lib/flutter-examples/manifest.generated.ts are out of step."
    if (process.env.NODE_ENV === "production") throw new Error(message)
    console.warn(`[flutter-examples] ${message}`)
  }

  const pixels = typeof height === "string" ? Number(height) : height
  const fixedHeight = Number.isFinite(pixels) && (pixels as number) > 0 ? (pixels as number) : undefined

  return (
    <ExampleFrame
      exampleId={id}
      compiled={example !== undefined}
      preview={example?.preview ?? "example"}
      title={title}
      height={fixedHeight}
      isolate={isolate === true}
      code={code}
      layout={layout}
      files={example?.files ?? 0}
      helpers={example?.helpers ?? []}
      caption={caption}>
      {children}
    </ExampleFrame>
  )
}
