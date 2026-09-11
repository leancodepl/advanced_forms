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

From `../docs_app`, `npm run landing:build` runs the build and copies those four into `public/`. There is no
stylesheet to copy: the styles are Dart, and the build inlines them into `index.html`.

## Layout

| Path                         | What lives there                                                                                                                  |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `lib/main.server.dart`       | The entrypoint: the `<head>` (font preloads, theme bootstrap, Open Graph) and the `App`.                                          |
| `lib/app.dart`               | The page: header, hero, three sections with a live demo each, features, agent skill band, footer.                                 |
| `lib/components/`            | One file per section or shared piece, each with its styles in a `@css` getter; `example_frame.dart` is the window around a demo.  |
| `lib/examples.dart`          | Reads the demos from `../docs_app/content/landing/*.mdx` and maps them to the compiled bundle.                                    |
| `lib/highlight.dart`         | Build-time Dart syntax highlighting (`syntax_highlight_lite`) into `tk-*` spans, and their colours.                               |
| `lib/site.dart`              | URLs, copy, the package version from `../pubspec.yaml`. `SITE_URL` (a `--dart-define`) for previews.                              |
| `lib/palette.generated.dart` | The palette — `enum Palette`, `afLight`/`afDark` — generated from `../docs_app/palette.json` by `npm run palette:generate` there. |
| `lib/styles.dart`            | Fonts, the `--af-*` tokens (written from the palette), the reset and the container. See "Styles" below.                          |
| `web/fonts/`                 | Space Grotesk and JetBrains Mono, self-hosted (see its README), so no third-party request blocks paint.                           |
| `web/landing.js`             | The client: Flutter islands, copy buttons, theme toggle. No framework, no build step.                                             |

## Styles

There is no stylesheet file. Every component declares the rules for the classes it renders in a
`@css static List<StyleRule> get styles` getter next to its `build`; `lib/styles.dart` holds what is not any one
component's: the `@font-face` rules, the `--af-*` tokens for the light (`:root`) and dark (`.dark`) themes — written
from `afLight` and `afDark` in `lib/palette.generated.dart`, so the colors come from `docs_app/palette.json` like the
docs' — the reset, the `af-container` column and the reduced-motion rule. `jaspr_builder` collects every `@css` getter
into `lib/main.server.options.dart` (generated, not committed), and Jaspr renders them as one `<style>` in the `<head>`
— global rules first, then components in file order — so nothing render-blocking is fetched.

A component owns the classes it renders, and the stylesheet is global, so class names are locally scoped by
[`jaspr_class_scope`](https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/jaspr_class_scope). A
component carries `@scopedCss` and a `part 'hero.scopes.dart'`, and its scope — `_$heroScope`, written by the builder
into that part file — makes its classes: `_class('af-grid')` renders as `af-grid-<suffix>`, unique to this component.
Both the selector (`css(_hero.selector)`, `'${_grid.selector} > *'`) and the attribute
(`classes: _hero.name`, `(container + _grid).name`) are spelled from the constant, so the suffix is never written by
hand, a rename cannot miss a use, and two components may pick the same local name without meeting in the stylesheet.
Nothing styles or renders another component's class
by string: a piece two places need is its own component — `CopyButton`, `Logo`, `ButtonRow`, the `Card` family, the
`Section` vocabulary (`Eyebrow`, `Lead`, `Checklist`, `MoreLink`, `DemoSlot`) — and where a parent has to reach into a
child, the child exports the constant (`CopyButton.labelClassName`, hidden by the hero's install line on narrow
screens). Variants are enum values carrying their class (`ButtonVariant`, `CopyButtonVariant`), and `Card`/`CardGrid`
take a caller's `className` for the caller's own rules on them. `ClassName.shared` renders a name as written, for the
classes that are a contract with another file: the ones `web/landing.js` looks up (`af-example*`, `af-tab-input`,
`af-code-panel`), the ones the docs' `global.css` uses for the same example frame and logo, `af-landing`, and the
`af-container` utility.

Jaspr's typed properties cover most of it; what they cannot say (`color-mix()`, `:has()`, `counter()`, an `infinite`
animation, a `@font-face` with a weight range) goes into the `raw` map of the same rule. Where two files style the same
element, the cascade follows the bundle order — files alphabetically, getters alphabetically within a file — so a
`Card` rule in `card.dart` is refined by the mode card's `className` rules in `sections.dart`.

## Fonts

`web/fonts/` holds Space Grotesk and JetBrains Mono as variable fonts in their Latin and Latin Extended subsets, under
the SIL Open Font License (the `OFL-*.txt` files alongside). Self-hosting them means no third-party stylesheet blocks the first
paint; `lib/styles.dart` opens with the `@font-face` rules and `main.server.dart` preloads the two Latin files, which
carry every glyph above the fold. To update a font, fetch the Google Fonts CSS with a modern Chrome user agent and copy
the `woff2` files it points at.

## Live demos

The four demos are the same `<AdvancedFormsExample>` blocks the docs use, kept in `../docs_app/content/landing/` so the
docs app's pipeline compiles them into the Flutter bundle at `/flutter-examples/`. At build time this site reads the
Dart from those MDX files to display it, and `web/landing.js` attaches each demo as a view of that one Flutter engine
when it scrolls near — the multi-view embedding the docs use, mirrored in plain JavaScript.

The theme is a `dark` class on `<html>`, stored under the same `theme` key as the docs, so a visitor's choice carries
over between the two.
