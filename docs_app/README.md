<!--
AI-Provenance:
  model: Claude Fable 5.1
  harness: Claude Code
-->

# advanced-forms-docs

The documentation site for `advanced_forms`, under `/docs`: built with [Fumadocs](https://fumadocs.dev) on Next.js,
styled after the LeanCode design system used on [ciach.leancode.co](https://ciach.leancode.co), and running its own code
examples in Flutter, in the browser. The landing page at `/` is a separate static site written in
[Jaspr](https://jaspr.site), in the repo-root `landing/` folder; this app serves its build output from `public/`, so the
two ship as one deployment on one domain.

MDX for the docs lives in the repo-root `docs/` folder; the landing page's live demos live in `content/landing/`. From
this directory:

```bash
npm run landing:build && npm run dev
```

Open http://localhost:3000. Node 22, the Flutter SDK and the Dart SDK with the Jaspr CLI
(`dart pub global activate jaspr_cli 0.23.4`) are required. `landing:build` only has to be repeated when `landing/`
changes; `npm run dev` without it serves the docs and 404s on `/`.

## Layout

| Path                                  | What lives there                                                                                                                |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `../docs/*.mdx`, `../docs/meta.json`  | The documentation pages and their order. Section separators are `---Name---` entries in `meta.json`.                            |
| `content/landing/*.mdx`               | The landing page's live demos: the Dart the Jaspr site shows and compiles, written like any docs example.                       |
| `../landing/`                         | The landing page, a Jaspr static site. `scripts/landing.mjs` builds it and copies the result into `public/`.                    |
| `app/docs/`                           | The notebook layout and the page renderer for `/docs/*`.                                                                        |
| `palette.json`, `scripts/palette.mjs` | The palette — the LeanCode swatches and the light and dark `--af-*` tokens — and the generator that writes every copy of it.    |
| `app/global.css`                      | The stylesheet: the Fumadocs variables mapped onto the `--af-*` tokens (generated into `app/af-tokens.css`), the example frame. |
| `lib/shared.ts`                       | Routes, external URLs, site copy.                                                                                               |
| `lib/layout.shared.tsx`               | The header: logo (`components/nav-title.tsx`, a plain link to the landing page), links, GitHub.                                 |
| `components/mdx.tsx`                  | The components MDX can use: Fumadocs' set, plus `Tabs`, `Steps`, `Accordions`, `TypeTable` and `AdvancedFormsExample`.          |
| `app/og/`                             | Branded Open Graph images, one per docs page.                                                                                   |

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
| `flutter/web/flutter_bootstrap.js`           | Engine config: multi-view, one surface per view (see the comment there)   |
| `public/flutter-examples/`                   | Build output, gitignored                                                  |

## Design

The colors are the LeanCode design system — black ground, warm surfaces, one CTA yellow `#f0ff00` — and live in one
place, `palette.json`: the swatches as the design system names them, and the light and dark themes as `--af-*` tokens
built from them. `npm run palette:generate` writes every copy a consumer needs (`app/af-tokens.css` for this stylesheet,
`lib/palette.generated.ts` for the social cards and the logo, `flutter/lib/support/palette.generated.dart` for the live
demos, `../landing/lib/palette.generated.dart` for the landing page, which writes its own `--af-*` variables from it)
and recolors the shapes marked `data-palette` in the logo and icon SVGs; `npm run palette:check` fails CI when they
drift. The stylesheet is hand-written on top of the Fumadocs preset, with the `--color-fd-*` variables Fumadocs paints
with pointed at the tokens. Space Grotesk and JetBrains Mono. Dark is the design and the default; light is a paper
variant where the accent is a fill with black ink on it, the way leancode.co does it.

Code blocks and live examples share one window frame: a title bar with three dots (the first one yellow), a mono title,
and the content below. The landing page (`../landing/lib/styles.dart` writes the tokens from the generated palette, the
components style the frame) uses the same tokens and the same frame, so the homepage and the docs read as one site.

## Deployment

One Next.js app, one Vercel project: the Jaspr landing page (copied into `public/`, with `/` rewritten to `/index.html`
in `next.config.mjs`), the docs, the search API, the Open Graph images, the Markdown endpoints and the Flutter bundle
under `public/flutter-examples/` all ship in a single deployment, and Next handles the routing for every page.

`npm run build` runs `jaspr build` and `flutter build web`, so **the Dart and Flutter SDKs have to be present where the
site is built**. Vercel's build container has neither, so `vercel.json` turns Vercel's own Git deployments off and
`.github/workflows/docs.yml` builds and deploys instead, with `vercel build` + `vercel deploy --prebuilt`:

| Event                          | Deploys                                                                 |
| ------------------------------ | ----------------------------------------------------------------------- |
| push to `main`                 | production                                                              |
| pull request touching the docs | a preview of the same project; the URL is commented on the pull request |

A pull request from a fork runs the build job only, since it has no access to the secrets. The deploy job needs the
`VERCEL_TOKEN` repository secret and the `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` repository variables (Settings →
Secrets and variables → Actions; the ids come from `vercel link` on the existing project). Without the token the deploy
job does nothing and the build job still guards every pull request. The Vercel project's **Root Directory** is
`docs_app`, so the workflow runs the Vercel CLI from the repository root and lets the CLI step into it.

## Routes

| Route                                                 | Description                                                            |
| ----------------------------------------------------- | ---------------------------------------------------------------------- |
| `/` → `public/index.html`                             | The landing page, built from `../landing` by `npm run landing:build`   |
| `app/docs/[[...slug]]`                                | Documentation pages                                                    |
| `app/api/search/route.ts`                             | Search                                                                 |
| `app/llms.txt` / `app/llms-full.txt` / `app/llms.mdx` | LLM markdown endpoints; `/docs/<page>.md` serves a page's Markdown     |
| `app/og`                                              | Open Graph images: one per docs page, `og/landing.png` for the landing |
| `app/robots.ts` / `app/sitemap.ts`                    | `robots.txt` and a sitemap of the landing page and every docs page     |
