/*
 * AI-Provenance:
 *   model: Claude Fable 5.1
 *   harness: Claude Code
 *
 * Everything on the landing page that needs a script: the live Flutter
 * examples, the copy buttons and the theme toggle. The page itself is static
 * HTML rendered by Jaspr, so this file is the whole client.
 *
 * The examples are views of ONE Flutter engine, the docs app's bundle served
 * from /flutter-examples/ on the same domain (multi-view embedding). Each
 * `.af-example-stage[data-example-id]` becomes a view when it scrolls near.
 * This mirrors docs_app/lib/flutter-examples/runtime.ts; keep the two in step.
 */
(() => {
  "use strict";

  const bundleBase = "/flutter-examples/";

  // Views alive at once, two WebGL contexts each; browsers cap live contexts
  // at about 16.
  const maxAttachedViews = 4;

  // ---------- Theme ----------

  const root = document.documentElement;

  function applyTheme(dark) {
    root.classList.toggle("dark", dark);
    root.style.colorScheme = dark ? "dark" : "light";
  }

  for (const toggle of document.querySelectorAll("[data-theme-toggle]")) {
    toggle.addEventListener("click", () => {
      const dark = !root.classList.contains("dark");
      applyTheme(dark);
      try {
        // The same key next-themes uses in the docs, so the choice carries over.
        localStorage.setItem("theme", dark ? "dark" : "light");
      } catch {
        // Storage may be unavailable; the toggle still works for this page.
      }
    });
  }

  // ---------- Copy buttons ----------

  function flashCopied(button) {
    button.dataset.copied = "true";
    setTimeout(() => delete button.dataset.copied, 2000);
  }

  for (const button of document.querySelectorAll("[data-copy-text]")) {
    button.addEventListener("click", () => {
      navigator.clipboard.writeText(button.dataset.copyText).then(
        () => flashCopied(button),
        () => undefined,
      );
    });
  }

  for (const button of document.querySelectorAll("[data-copy]")) {
    button.addEventListener("click", () => {
      // The visible panel is the one whose radio is checked.
      const code = button.closest(".af-example-code");
      const inputs = [...code.querySelectorAll(":scope > .af-tab-input")];
      const index = inputs.findIndex(input => input.checked);
      const panel = code.querySelectorAll(".af-code-panel")[Math.max(index, 0)];
      const pre = panel?.querySelector("pre");
      if (!pre) return;
      navigator.clipboard.writeText(pre.textContent ?? "").then(
        () => flashCopied(button),
        () => undefined,
      );
    });
  }

  // ---------- Page title ----------

  // Every island is a MaterialApp, and MaterialApp renders a Title widget with
  // an empty title; the engine forwards that to `document.title`, so the tab
  // shows the address instead of the page title the moment a demo starts.
  // Writes of an empty title are ignored; real titles still go through.
  {
    const title = Object.getOwnPropertyDescriptor(Document.prototype, "title");
    if (title?.get && title?.set) {
      Object.defineProperty(document, "title", {
        configurable: true,
        get() {
          return title.get.call(this);
        },
        set(value) {
          if (String(value).trim() !== "") title.set.call(this, value);
        },
      });
    }
  }

  // ---------- Flutter engine ----------

  let engine;

  function loadEngine() {
    engine ??= new Promise((resolve, reject) => {
      // The docs app may already have started the engine on this page.
      if (window.__advancedFormsIslands) {
        window.__advancedFormsIslands.then(resolve, reject);
        return;
      }
      // The loader resolves asset URLs against document.baseURI; anchor them.
      window.__advancedFormsIslandsConfig = { assetBase: bundleBase };

      const script = document.createElement("script");
      script.src = `${bundleBase}flutter_bootstrap.js`;
      script.async = true;
      script.addEventListener("load", () => {
        const app = window.__advancedFormsIslands;
        if (app) app.then(resolve, reject);
        else reject(new Error("flutter_bootstrap.js did not publish window.__advancedFormsIslands"));
      });
      script.addEventListener("error", () => {
        reject(new Error(`Could not load ${bundleBase}flutter_bootstrap.js`));
      });
      document.head.append(script);
    });
    return engine;
  }

  /**
   * A small pool of views, never removed: every view owns two WebGL contexts
   * (see flutter/web/flutter_bootstrap.js in docs_app), the engine does not
   * give them back on removeView, and browsers revoke the oldest live context
   * once about sixteen exist. An island that stops being used parks its view
   * off screen; the next island that needs one takes a parked view and points
   * it at its own example (`__advancedFormsIslandsSetExample`, main.dart).
   * Entries: { viewId, host, exampleId, request, parkedAt }.
   */
  const pool = [];
  let queue = Promise.resolve();
  const nextFrame = () => new Promise(resolve => requestAnimationFrame(() => resolve()));

  let parkingLot;

  function park(view) {
    if (!parkingLot) {
      parkingLot = document.createElement("div");
      parkingLot.setAttribute("aria-hidden", "true");
      parkingLot.style.cssText =
        "position:fixed;top:0;left:-200vw;width:640px;height:0;overflow:visible;visibility:hidden;pointer-events:none";
      document.body.append(parkingLot);
    }
    view.request = undefined;
    view.parkedAt = performance.now();
    parkingLot.append(view.host);
  }

  function detach(view, evicted) {
    if (!view.request) return;
    const { onEvicted } = view.request;
    park(view);
    if (evicted) onEvicted();
  }

  /** The view to re-aim when the pool is full: parked and least recently used, else the least visible. */
  function reclaim() {
    const parked = pool.filter(view => !view.request).sort((a, b) => a.parkedAt - b.parkedAt);
    if (parked.length > 0) return parked[0];
    const victim = pool.find(view => !view.request.isVisible()) ?? pool[0];
    if (victim) detach(victim, true);
    return victim;
  }

  /** Gives one island a view, serialized: views laid out in one frame can share a size. */
  function attachView(request) {
    const attach = async () => {
      const app = await loadEngine();
      let view = pool.find(candidate => !candidate.request && candidate.exampleId === request.exampleId);
      if (!view && pool.length < maxAttachedViews) {
        const host = document.createElement("div");
        host.style.cssText = "display:block;width:100%;height:100%";
        request.container.append(host);
        view = {
          viewId: app.addView({
            hostElement: host,
            initialData: { exampleId: request.exampleId },
            // Auto-height: the engine sizes the host to its content.
            viewConstraints: { minHeight: 0, maxHeight: Infinity },
          }),
          host,
          exampleId: request.exampleId,
          parkedAt: 0,
        };
        pool.push(view);
      }
      if (!view) {
        view = reclaim();
        view.exampleId = request.exampleId;
        window.__advancedFormsIslandsSetExample?.(view.viewId, request.exampleId);
      }
      view.request = request;
      request.container.append(view.host);
      await nextFrame();
      await nextFrame();
      return view;
    };
    const result = queue.then(attach, attach);
    queue = result.catch(() => undefined);
    return result;
  }

  // ---------- Islands ----------

  const statusLabels = {
    idle: "idle",
    attaching: "starting",
    ready: "live · try it",
    evicted: "paused",
    failed: "offline",
  };

  // Touch devices need a gate: the engine sets `touch-action: none` on its view,
  // so an un-gated island swallows the scroll gesture.
  const needsGate = window.matchMedia("(hover: none) and (pointer: coarse)").matches;

  function notice(stage, text, action) {
    const box = document.createElement("div");
    box.className = "af-example-notice";
    const p = document.createElement("p");
    p.textContent = text;
    if (action) {
      const button = document.createElement("button");
      button.type = "button";
      button.textContent = action.label;
      button.addEventListener("click", action.run);
      p.append(button);
    }
    box.append(p);
    stage.append(box);
    return box;
  }

  function mountIsland(stage) {
    const example = stage.closest(".af-example");
    const status = example?.querySelector(".af-example-status");
    const host = document.createElement("div");
    host.style.display = "block";
    host.style.width = "100%";
    stage.append(host);

    let visible = false;
    let overlay;

    function setStatus(state) {
      if (status) {
        status.dataset.status = state;
        status.textContent = statusLabels[state];
      }
      stage.dataset.settled = String(state === "ready");
    }

    function clearOverlay() {
      overlay?.remove();
      overlay = undefined;
    }

    function start() {
      clearOverlay();
      setStatus("attaching");
      attachView({
        container: host,
        exampleId: stage.dataset.exampleId,
        isVisible: () => visible,
        onEvicted: () => {
          setStatus("evicted");
          overlay = notice(stage, "Paused to stay within the browser's rendering budget.", {
            label: "Resume",
            run: start,
          });
        },
      }).then(
        () => {
          setStatus("ready");
          if (needsGate) gate();
        },
        error => {
          setStatus("failed");
          overlay = notice(stage, `The live example could not be loaded. ${error?.message ?? ""}`);
        },
      );
    }

    function gate() {
      host.style.pointerEvents = "none";
      const button = document.createElement("button");
      button.type = "button";
      button.className = "af-example-gate";
      button.innerHTML = "<span>Try it</span>";
      button.addEventListener("click", () => {
        host.style.pointerEvents = "";
        button.remove();
        const done = document.createElement("button");
        done.type = "button";
        done.className = "af-example-gate-done";
        done.textContent = "Done";
        done.addEventListener("click", () => {
          done.remove();
          gate();
        });
        stage.append(done);
      });
      stage.append(button);
    }

    const observer = new IntersectionObserver(
      entries => {
        for (const entry of entries) {
          visible = entry.isIntersecting;
          if (entry.isIntersecting && stage.dataset.state !== "started") {
            stage.dataset.state = "started";
            start();
          }
        }
      },
      // Start loading before the reader arrives.
      { rootMargin: "400px 0px" },
    );
    observer.observe(stage);
  }

  for (const stage of document.querySelectorAll(".af-example-stage[data-example-id]")) {
    mountIsland(stage);
  }
})();
