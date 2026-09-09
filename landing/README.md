<!--
AI-Provenance:
  model: Claude Fable 5.1
  harness: Claude Code
-->

# advanced_forms landing page

The homepage at [advanced-forms.leancode.co](https://advanced-forms.leancode.co): a static site written in
[Jaspr](https://jaspr.site), rendered once at build time to a single `index.html`. The documentation under `/docs` is
the Fumadocs app in `../docs_app`, which serves this page's build output from its `public/` folder — one deployment,
one domain.

```bash
dart pub global activate jaspr_cli 0.23.4
dart pub get
jaspr serve        # http://localhost:8080, rebuilds on change
jaspr build        # build/jaspr/{index.html,landing.css,landing.js,landing-icon.svg}
```

From `../docs_app`, `npm run landing:build` runs the build and copies those four files into `public/`.

## Layout

| Path                    | What lives there                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------------------ |
| `lib/main.server.dart`  | The entrypoint: the `<head>` (fonts, theme bootstrap, Open Graph) and the `App`.                 |
| `lib/app.dart`          | The page: header, hero, three sections with a live demo each, features, agent skill band, footer. |
| `lib/components/`       | One file per section; `example_frame.dart` is the window around a live demo.                     |
| `lib/examples.dart`     | Reads the demos from `../docs_app/content/landing/*.mdx` and maps them to the compiled bundle.    |
| `lib/highlight.dart`    | Build-time Dart syntax highlighting (`syntax_highlight_lite`) into `tk-*` spans.                 |
| `lib/site.dart`         | URLs, copy, the package version from `../pubspec.yaml`. `SITE_URL` (a `--dart-define`) for previews. |
| `web/af-tokens.css`     | The `--af-*` color tokens, generated from `../docs_app/palette.json` by `npm run palette:generate` there; the docs use the same file. |
| `web/landing.css`       | The stylesheet: everything but the colors, dark by default.                                      |
| `web/landing.js`        | The client: Flutter islands, copy buttons, theme toggle. No framework, no build step.            |

## Live demos

The four demos are the same `<AdvancedFormsExample>` blocks the docs use, kept in `../docs_app/content/landing/` so the
docs app's pipeline compiles them into the Flutter bundle at `/flutter-examples/`. At build time this site reads the
Dart from those MDX files to display it, and `web/landing.js` attaches each demo as a view of that one Flutter engine
when it scrolls near — the multi-view embedding the docs use, mirrored in plain JavaScript.

The theme is a `dark` class on `<html>`, stored under the same `theme` key as the docs, so a visitor's choice carries
over between the two.
