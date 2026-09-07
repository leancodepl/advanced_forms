// AI-Provenance:
//   model: Claude Opus 5
//   harness: Cursor
//
// Replaces the default bootstrap so the bundle never takes over the page.
// Multi-view mode renders nothing until the host calls `addView`, so loading
// this script is cheap and idempotent: it starts one engine and publishes the
// resulting app object on `window.__advancedFormsIslands`.
{{flutter_js}}
{{flutter_build_config}}

(() => {
  // `window.__advancedFormsIslandsConfig` is a partial Flutter engine config
  // the host page may set before this script runs — the docs app uses it to
  // point at the bundle, and it is the seam for e.g. forcing CPU rendering in a
  // test browser.
  const overrides = window.__advancedFormsIslandsConfig || {};

  // `resolveUrlWithSegments` resolves against `document.baseURI`, and the docs
  // pages that host the islands have no <base> tag, so every URL the loader
  // builds has to be anchored explicitly. That includes CanvasKit: the build
  // config sets `useLocalCanvasKit`, which without this resolves `canvaskit/`
  // against the *page* URL.
  const assetBase = overrides.assetBase || "/flutter-examples/";

  const config = {
    renderer: "canvaskit",
    multiViewEnabled: true,
    // One shared surface for every view, the engine's default. The
    // multi-surface rasterizer gives each view its own WebGL context and the
    // engine keeps allocating them across view add/remove cycles, until the
    // browser starts revoking the oldest ones: the islands flicker and then
    // go blank ("Too many active WebGL contexts"). The size race the shared
    // rasterizer has when several views first render in the same frame
    // (flutter/flutter#185034) is avoided by attaching one island at a time,
    // in runtime.ts.
    // One CanvasKit for every browser. `auto` would try the Chromium-only
    // build first, which the bundle no longer ships, costing a 404 per load.
    canvasKitVariant: "full",
    ...overrides,
    assetBase,
    entrypointBaseUrl: overrides.entrypointBaseUrl || assetBase,
    // Only the release build self-hosts CanvasKit (`--no-web-resources-cdn`).
    // `flutter run` serves it from the CDN, and pointing at a `canvaskit/` the
    // dev server does not have would break the authoring loop.
    canvasKitBaseUrl:
      overrides.canvasKitBaseUrl ||
      (_flutter.buildConfig.useLocalCanvasKit ? `${assetBase}canvaskit/` : undefined),
  };

  window.__advancedFormsIslands = new Promise((resolve, reject) => {
    _flutter.loader.load({
      config,
      // Supplying this callback means the loader no longer initializes the
      // engine for us, so `config` has to be forwarded by hand, and `load()`
      // resolves with nothing.
      onEntrypointLoaded: (engineInitializer) =>
        engineInitializer
          .initializeEngine(config)
          .then(appRunner => appRunner.runApp())
          .then(resolve, reject),
    });
  });
})();
