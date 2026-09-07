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

  // Each view is a rendering surface; browsers stop handing WebGL contexts out
  // somewhere around 16, and the shared rasterizer needs one per page anyway.
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

  /** Attached views, oldest first: { viewId, stage, isVisible, detached }. */
  const attached = [];
  let queue = Promise.resolve();
  const nextFrame = () => new Promise(resolve => requestAnimationFrame(() => resolve()));

  function detach(entry, evicted) {
    if (entry.detached) return;
    entry.detached = true;
    const index = attached.indexOf(entry);
    if (index !== -1) attached.splice(index, 1);
    loadEngine().then(app => app.removeView(entry.viewId));
    if (evicted) entry.onEvicted();
  }

  function makeRoom() {
    while (attached.length >= maxAttachedViews) {
      detach(attached.find(entry => !entry.isVisible()) ?? attached[0], true);
    }
  }

  /** Adds one view, serialized: views laid out in one frame can share a size. */
  function attachView(request) {
    const attach = async () => {
      const app = await loadEngine();
      makeRoom();
      const entry = {
        viewId: app.addView({
          hostElement: request.host,
          initialData: { exampleId: request.exampleId },
          // Auto-height: the engine sizes the host to its content.
          viewConstraints: { minHeight: 0, maxHeight: Infinity },
        }),
        isVisible: request.isVisible,
        onEvicted: request.onEvicted,
        detached: false,
      };
      attached.push(entry);
      await nextFrame();
      await nextFrame();
      return entry;
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
        host,
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
