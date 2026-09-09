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
jaspr build        # build/jaspr/{index.html,landing.js,landing-icon.svg,fonts/}
```

From `../docs_app`, `npm run landing:build` runs the build and copies those four into `public/`. The stylesheet is
inlined into `index.html`, so it is not copied on its own.

## Layout

| Path                   | What lives there                                                                                                 |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `lib/main.server.dart` | The entrypoint: the `<head>` (font preloads, the inlined stylesheet, theme bootstrap, Open Graph) and the `App`. |
| `lib/app.dart`         | The page: header, hero, three sections with a live demo each, features, agent skill band, footer.                |
| `lib/components/`      | One file per section; `example_frame.dart` is the window around a live demo.                                     |
| `lib/examples.dart`    | Reads the demos from `../docs_app/content/landing/*.mdx` and maps them to the compiled bundle.                   |
| `lib/highlight.dart`   | Build-time Dart syntax highlighting (`syntax_highlight_lite`) into `tk-*` spans.                                 |
| `lib/site.dart`        | URLs, copy, the package version from `../pubspec.yaml`. `SITE_URL` (a `--dart-define`) for previews.             |
| `web/landing.css`      | The stylesheet: the same `--af-*` tokens as `docs_app/app/global.css`, dark by default. Inlined at build.        |
| `web/fonts/`           | Space Grotesk and JetBrains Mono, self-hosted (see its README), so no third-party request blocks paint.          |
| `web/landing.js`       | The client: Flutter islands, copy buttons, theme toggle. No framework, no build step.                            |

## Fonts

`web/fonts/` holds Space Grotesk and JetBrains Mono as variable fonts in their Latin and Latin Extended subsets, the
same files [ciach.leancode.co](https://github.com/leancodepl/ciach/tree/main/website/web/fonts) ships, under the SIL
Open Font License (the `OFL-*.txt` files alongside). Self-hosting them means no third-party stylesheet blocks the first
paint; `landing.css` opens with the `@font-face` rules and `main.server.dart` preloads the two Latin files, which carry
every glyph above the fold. To update a font, fetch the Google Fonts CSS with a modern Chrome user agent and copy the
`woff2` files it points at.

## Live demos

The four demos are the same `<AdvancedFormsExample>` blocks the docs use, kept in `../docs_app/content/landing/` so the
docs app's pipeline compiles them into the Flutter bundle at `/flutter-examples/`. At build time this site reads the
Dart from those MDX files to display it, and `web/landing.js` attaches each demo as a view of that one Flutter engine
when it scrolls near — the multi-view embedding the docs use, mirrored in plain JavaScript.

The theme is a `dark` class on `<html>`, stored under the same `theme` key as the docs, so a visitor's choice carries
over between the two.
