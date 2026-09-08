/*
 * AI-Provenance:
 *   model: Claude Opus 5
 *   harness: Cursor
 *   edited-by: Claude Fable 5.1 (Claude Code)
 */
"use client"

/**
 * One Flutter engine per page, shared by every island on it.
 *
 * Multiple Flutter *engines* on one page are not supported and never will be —
 * they fight over globals on `window`. Multi-view embedding is the supported
 * shape: a single engine that renders into any number of host elements. This
 * module owns that engine and hands out views from a small pool.
 *
 * The pool, rather than adding and removing views as islands come and go:
 * every view owns two WebGL contexts (see flutter/web/flutter_bootstrap.js),
 * the engine does not give them back on `removeView`, and browsers revoke the
 * oldest live context once about sixteen exist — an island still on screen
 * then flickers and goes blank. So a view is created at most `poolSize` times
 * per page load and never removed: an island that unmounts parks its view off
 * screen, and the next island that needs one takes a parked view and points it
 * at its own example (`__advancedFormsIslandsSetExample`, see main.dart). A
 * reader who scrolls back to an example still parked gets it back as they left
 * it. landing/web/landing.js mirrors this file; keep the two in step.
 */

/** Where `flutter build web -o` puts the bundle, relative to the site root. */
const bundleBase = "/flutter-examples/"

/**
 * Views alive at once, and so the most islands that can run on one page.
 * Two WebGL contexts each, plus the engine's own few, stays well under the
 * browser cap of about sixteen.
 */
const poolSize = 4

interface ViewConstraints {
  minWidth?: number
  maxWidth?: number
  minHeight?: number
  maxHeight?: number
}

interface FlutterApp {
  addView(options: { hostElement: Element; initialData?: unknown; viewConstraints?: ViewConstraints }): number
  removeView(viewId: number): void
}

declare global {
  interface Window {
    __advancedFormsIslands?: Promise<FlutterApp>
    __advancedFormsIslandsConfig?: { assetBase?: string }
    /** Installed by the Flutter side (main.dart) once the engine runs. */
    __advancedFormsIslandsSetExample?: (viewId: number, exampleId: string | null) => void
  }
}

/**
 * Every island is a MaterialApp, and MaterialApp renders a Title widget with an
 * empty title; the engine forwards that to `document.title`, so the tab shows
 * the address instead of the page title the moment a demo starts. Writes of an
 * empty title are ignored; the titles Next sets still go through.
 */
function keepPageTitle() {
  const title = Object.getOwnPropertyDescriptor(Document.prototype, "title")
  if (!title?.get || !title.set || Object.getOwnPropertyDescriptor(document, "title")) return
  const { get, set } = title
  Object.defineProperty(document, "title", {
    configurable: true,
    get() {
      return get.call(this)
    },
    set(value: string) {
      if (String(value).trim() !== "") set.call(this, value)
    },
  })
}

let engine: Promise<FlutterApp> | undefined

function loadEngine(): Promise<FlutterApp> {
  engine ??= new Promise<FlutterApp>((resolve, reject) => {
    keepPageTitle()

    // The loader resolves asset URLs against `document.baseURI`, and a Next.js
    // page has no <base> tag, so the bundle location has to be spelled out.
    window.__advancedFormsIslandsConfig = { assetBase: bundleBase }

    const script = document.createElement("script")
    script.src = `${bundleBase}flutter_bootstrap.js`
    script.async = true

    script.addEventListener("load", () => {
      const app = window.__advancedFormsIslands
      if (app) app.then(resolve, reject)
      else reject(new Error("flutter_bootstrap.js did not publish window.__advancedFormsIslands"))
    })
    script.addEventListener("error", () => {
      reject(new Error(`Could not load ${bundleBase}flutter_bootstrap.js — run \`npm run examples:build\`.`))
    })

    document.head.append(script)
  })

  return engine
}

export interface IslandRequest {
  /** Where the view goes. The runtime appends its own host element to it. */
  container: HTMLElement
  exampleId: string
  /** Omit for a fixed-height island: the engine then measures the host. */
  viewConstraints?: ViewConstraints
  /** Whether this island is on or near the screen, asked when making room. */
  isVisible: () => boolean
  /** Called when the view is taken away to serve another island. */
  onEvicted: () => void
}

export interface AttachedIsland {
  detach(): void
}

/** One pooled view: created once, re-aimed and re-parented for its whole life. */
interface PooledView {
  viewId: number
  /** The element the engine renders into; moves between containers and the lot. */
  host: HTMLDivElement
  /** Auto-height views and fixed-height views have different constraints, set at creation. */
  auto: boolean
  exampleId: string
  /** The island using the view right now, if any. */
  request?: IslandRequest
  /** When the view was last parked; the least recently used one is re-aimed first. */
  parkedAt: number
}

const pool: PooledView[] = []

let queue: Promise<unknown> = Promise.resolve()

const nextFrame = () => new Promise<void>(resolve => requestAnimationFrame(() => resolve()))

/**
 * Where parked views live: off screen but laid out, so the engine keeps a
 * sensible width and never sees a zero-sized view.
 */
let parkingLot: HTMLDivElement | undefined

function park(view: PooledView) {
  if (!parkingLot) {
    parkingLot = document.createElement("div")
    parkingLot.setAttribute("aria-hidden", "true")
    parkingLot.style.cssText =
      "position:fixed;top:0;left:-200vw;width:640px;height:0;overflow:visible;visibility:hidden;pointer-events:none"
    document.body.append(parkingLot)
  }
  view.request = undefined
  view.parkedAt = performance.now()
  parkingLot.append(view.host)
}

function place(view: PooledView, request: IslandRequest) {
  view.request = request
  request.container.append(view.host)
}

function detach(view: PooledView, evicted = false) {
  if (!view.request) return
  const { onEvicted } = view.request
  park(view)
  if (evicted) onEvicted()
}

function makeHost() {
  const host = document.createElement("div")
  host.style.cssText = "display:block;width:100%;height:100%"
  return host
}

/** The view to re-aim when the pool is full: parked and least recently used, else the least visible. */
function reclaim(auto: boolean): PooledView | undefined {
  const candidates = pool.filter(view => view.auto === auto)
  const parked = candidates.filter(view => !view.request).sort((a, b) => a.parkedAt - b.parkedAt)
  if (parked.length > 0) return parked[0]
  const victim = candidates.find(view => !view.request?.isVisible()) ?? candidates[0]
  if (victim) detach(victim, true)
  return victim
}

/**
 * Gives one island a view, serialized against every other island on the page.
 *
 * The serialization is deliberate: views that first lay out in the same frame
 * can end up sharing a size (flutter/flutter#185034), so each one is given a
 * couple of frames to settle before the next is touched.
 */
export function attachIsland(request: IslandRequest): Promise<AttachedIsland> {
  const auto = request.viewConstraints !== undefined

  const attach = async (): Promise<AttachedIsland> => {
    const app = await loadEngine()

    // A parked view still showing this very example: the reader gets it back
    // exactly as they left it.
    let view = pool.find(
      candidate => !candidate.request && candidate.auto === auto && candidate.exampleId === request.exampleId,
    )

    if (!view && pool.length < poolSize) {
      const host = makeHost()
      request.container.append(host)
      view = {
        viewId: app.addView({
          hostElement: host,
          initialData: { exampleId: request.exampleId },
          viewConstraints: request.viewConstraints,
        }),
        host,
        auto,
        exampleId: request.exampleId,
        parkedAt: 0,
      }
      pool.push(view)
    }

    if (!view) {
      view = reclaim(auto)
      if (!view) throw new Error("No Flutter view available for this island.")
      view.exampleId = request.exampleId
      window.__advancedFormsIslandsSetExample?.(view.viewId, request.exampleId)
    }

    place(view, request)

    await nextFrame()
    await nextFrame()

    const placed = view
    return { detach: () => detach(placed) }
  }

  const result = queue.then(attach, attach)
  queue = result.catch(() => undefined)
  return result
}

/** The constraints for an island whose height follows its content. */
export const autoHeightConstraints: ViewConstraints = { minHeight: 0, maxHeight: Infinity }
