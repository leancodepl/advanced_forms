<!--
AI-Provenance:
  model: Claude Fable 5.1
  harness: Claude Code
-->

# advanced-forms-docs

The documentation site for `advanced_forms`: a landing page at `/` and the docs under `/docs`, built with
[Fumadocs](https://fumadocs.dev) on Next.js, styled after the LeanCode design system used on
[ciach.leancode.co](https://ciach.leancode.co), and running its own code examples in Flutter, in the browser.

MDX for the docs lives in the repo-root `docs/` folder; the landing page's live demos live in `content/landing/`. From
this directory:

```bash
npm run dev
```

Open http://localhost:3000. Node 22 and the Flutter SDK are required.

## Layout

| Path                                 | What lives there                                                                                                       |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| `../docs/*.mdx`, `../docs/meta.json` | The documentation pages and their order. Section separators are `---Name---` entries in `meta.json`.                   |
| `content/landing/*.mdx`              | The landing page's live demos: MDX blocks the page embeds, compiled like any docs example.                             |
| `app/(home)/page.tsx`                | The landing page. Sections are in `components/landing/`.                                                               |
| `app/docs/`                          | The notebook layout and the page renderer for `/docs/*`.                                                               |
| `app/global.css`                     | The design system: tokens (`--af-*`), the Fumadocs variables they map onto, the landing classes, the example frame.    |
| `lib/shared.ts`                      | Routes, external URLs, site copy. `lib/version.ts` reads the package version from `../pubspec.yaml`.                   |
| `lib/layout.shared.tsx`              | The header shared by both layouts: logo, links, GitHub.                                                                |
| `components/mdx.tsx`                 | The components MDX can use: Fumadocs' set, plus `Tabs`, `Steps`, `Accordions`, `TypeTable` and `AdvancedFormsExample`. |
| `app/og/`                            | Branded Open Graph images, one per docs page.                                                                          |

## Live Flutter examples

A page can run the code it shows. Wrap the Dart fences in `<AdvancedFormsExample>` and the snippet is compiled into a
real Flutter app at build time, then rendered above the code:

````mdx
<AdvancedFormsExample preview="SignupForm" title="signup_form.dart">
  ```dart title="signup_form_controller.dart"
  class SignupFormController extends AdvancedFormController { ... }
  ```
  ```dart title="signup_form.dart"
  class SignupForm extends StatefulWidget { ... }
  ```
</AdvancedFormsExample>
````

Every `dart` fence inside the element is concatenated into one file, in document order, so an example may stay split
across the fences the prose needs. The generated file imports `package:flutter/material.dart`,
`package:advanced_forms/advanced_forms.dart` and a docs-only support library, so snippets carry no imports.

- `preview` names the widget to mount. Omit it and the first `class X extends StatelessWidget|StatefulWidget` is used.
  It needs a `const X({super.key})` constructor.
- `title` is shown in the frame's title bar. A `title="file.dart"` on a fence labels that fence.
- `code` is `open` (default), `collapsed` (behind a **Source** toggle) or `hidden` (the landing hero).
- `layout="split"` puts the code and the running example side by side, for wide sections.
- `height={320}` fixes the island's height. **An auto-height island must not use `Scaffold`**, which takes every pixel
  it is offered; use `height` for `Scaffold` and scrolling demos, and avoid `PageView` / `Expanded` without a height.
- `isolate` renders the example in an iframe instead of sharing the page's engine. Needs `height`. An escape hatch for
  an example that wants the page to itself.
- `caption` adds a line under the example.
- The `Docs*` widgets from `flutter/lib/support/fields.dart` — `DocsTextField`, `DocsDropdownField`, `DocsChipsField`,
  `DocsSwitchField`, `DocsCheckboxField`, `DocsSubmitButton`, `DocsFormStatus`, `DocsFieldStatus`, `DocsFailureBanner`,
  `DocsHint`, `DocsActions` — keep examples about validation from re-teaching `AdvancedFieldBuilder`. Using one makes
  the frame say so on the page, so nobody copies it into an app expecting it to exist. An example _about_ widget wiring
  should write its own widgets instead.
- `ExampleLog.of(context).add('…')` prints to the **Output** panel under the running example. It is the one docs-only
  call that appears in published snippets.

All the islands on a page share **one** Flutter engine, in
[multi-view mode](https://docs.flutter.dev/platform-integration/web/embedding-flutter-web): one download, one warm-up,
and each island is a view attached to its own `<div>` when it scrolls into sight. The islands read the page's theme from
the `dark` class on `<html>`, and paint with the same tokens as the page (`flutter/lib/support/island_frame.dart`).

### Working on an example

Islands on a page you are reading come from the last `npm run examples:build`; if that never ran they degrade to plain
code blocks with a note. Three loops, in the order you are likely to want them:

**Writing a snippet.** Format it, rebuild the bundle and reload:

```bash
npm run examples:format                 # dart format, applied to the fences in the MDX
npm run examples:build && npm run dev   # ~25s for the Flutter build
```

CI runs `dart format --set-exit-if-changed` over the generated files, so an unformatted snippet fails the build;
`examples:format` is what fixes it. Only fences inside `<AdvancedFormsExample>` are touched — a fence elsewhere may be a
fragment the formatter cannot parse.

**Iterating on an example's Dart, with hot reload.** The Flutter package has a standalone gallery that mounts any single
example by id:

```bash
cd flutter && flutter run -d chrome     # then `r` to hot reload
```

**Live islands inside the real docs page.** Point the docs at the Flutter dev server instead of the built bundle:

```bash
npm run examples:serve                                        # dev server on :5333
FLUTTER_EXAMPLES_DEV_SERVER=http://localhost:5333 npm run dev # docs, proxying it
npm run examples:watch                                        # regenerate Dart as MDX changes
```

Then edit the MDX, press `r` in the Flutter terminal, reload the page. This one needs the
[Dart Debug Extension](https://chromewebstore.google.com/detail/dart-debug-extension/eljbmlghnomdjgdjmbdekegdkbabckhm)
installed in the browser you open the docs in: `flutter run -d web-server` waits for a debugger to attach before it
starts the app, so without the extension the island loads its code and then sits there. The rewrite exists because the
debug asset server sends no CORS headers, unlike the release one.

### How it fits together

| Path                                         | What it does                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------- |
| `lib/flutter-examples/extract.mjs`           | Pulls the Dart out of the MDX and hashes it into an example id            |
| `lib/flutter-examples/remark-example-id.ts`  | Stamps that id onto the element the page renders                          |
| `scripts/flutter-examples.mjs`               | `generate` / `check` / `build` / `--watch`, over `../docs` and `content/` |
| `scripts/format-snippets.mjs`                | `examples:format` — `dart format` for the fences, inside the MDX          |
| `lib/flutter-examples/manifest.generated.ts` | Committed id → metadata map, so `next build` can spot a stale bundle      |
| `flutter/`                                   | The Flutter package the snippets are compiled into                        |
| `components/advanced-forms-example.tsx`      | The MDX component; `components/example-frame.tsx` is the window around it |
| `components/flutter-island.tsx`              | Attaches and detaches one view                                            |
| `public/flutter-examples/`                   | Build output, gitignored                                                  |

## Design

The stylesheet is hand-written on top of the Fumadocs preset. Tokens are CSS custom properties prefixed `--af-` at the
top of `app/global.css` — the ciach palette: `#050505` ground, `#101013` surfaces, `#edff2f` accent, Space Grotesk and
JetBrains Mono — and the `--color-fd-*` variables Fumadocs paints with are re-pointed at them. Dark is the design and
the default; light is a paper variant where the accent is a fill with dark ink on it, the way leancode.co does it.

Code blocks and live examples share one window frame: a title bar with three dots (the first one lime), a mono title,
and the content below. The landing page's classes (`.af-hero`, `.af-section`, `.af-card`, …) mirror ciach's stylesheet
so the two sites read as one family.

## Deployment

`npm run build` runs `flutter build web`, so **the Flutter SDK has to be present where the site is built**. Vercel's
build container has no Flutter, so `vercel.json` turns its Git integration off and `.github/workflows/docs.yml` builds
and deploys instead, using `vercel deploy --prebuilt`. It needs three repository secrets: `VERCEL_TOKEN`,
`VERCEL_ORG_ID` and `VERCEL_PROJECT_ID`. Without them the deploy job does nothing and the build job still guards every
pull request.

## Routes

| Route                                                 | Description                                                        |
| ----------------------------------------------------- | ------------------------------------------------------------------ |
| `app/(home)`                                          | The landing page                                                   |
| `app/docs/[[...slug]]`                                | Documentation pages                                                |
| `app/api/search/route.ts`                             | Search                                                             |
| `app/llms.txt` / `app/llms-full.txt` / `app/llms.mdx` | LLM markdown endpoints; `/docs/<page>.md` serves a page's Markdown |
| `app/og`                                              | Open Graph images                                                  |
