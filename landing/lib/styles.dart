/// Design tokens and the site-wide rules: the fonts, the reset, typography and
/// the one layout utility. Everything else lives next to the component it
/// styles, in `@css` getters; Jaspr collects all of them into one stylesheet,
/// global rules first, and inlines it into the page's `<head>`.
///
/// The LeanCode design system: black surfaces, one CTA yellow, Space Grotesk
/// and JetBrains Mono. Dark is the design; light is a paper variant where the
/// accent is a fill with black ink on it. The colors come from
/// `docs_app/palette.json` through `palette.generated.dart`, and the docs app
/// under /docs paints with the same `--af-*` tokens, so the two read as one
/// site.
library;

import 'package:advanced_forms_landing/palette.generated.dart';
import 'package:jaspr/dom.dart';

// ---------- Class names ----------

/// Makes the class names of one component, scoped to it.
///
/// Jaspr collects every `@css` getter into one global stylesheet and scopes
/// nothing, so this does what CSS modules do at build time. A component
/// declares one scope and makes its classes from it:
///
/// ```dart
/// static const _class = ClassScope<Hero>();
/// static final _grid = _class('af-hero-grid');
/// ```
///
/// and `_grid` renders as `af-hero-grid-<suffix>`, the suffix a short hash of
/// the component's type name. Two components can both call something
/// `af-grid` and never meet in the stylesheet, and a raw `'af-grid'` string
/// elsewhere matches nothing. Selectors ([ClassName.selector]) and `classes:`
/// attributes ([ClassName.name]) are spelled from the constant, so the suffix
/// is never written by hand. Two scopes that would hash alike fail the build
/// the first time either renders, so a collision cannot slip through.
final class ClassScope<T> {
  const ClassScope();

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName._(local, this);

  /// Five base-36 digits of an FNV-1a hash of [T]'s name: the same on every
  /// machine and Dart version, and short enough to read in the inspector.
  String get suffix {
    var hash = 0x811c9dc5;
    for (final unit in T.toString().codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    final suffix = hash.toRadixString(36).padLeft(5, '0').substring(0, 5);
    final taken = _suffixes.putIfAbsent(suffix, () => T);
    if (taken != T) {
      throw StateError(
        'ClassScope<$T> and ClassScope<$taken> both scope to "-$suffix"; '
        'rename one of the components.',
      );
    }
    return suffix;
  }

  static final _suffixes = <String, Type>{};
}

/// A CSS class name: made by a [ClassScope] for the component that owns it, or
/// [ClassName.shared] for the classes that are a contract with another file —
/// the ones `web/landing.js` looks up, the ones the docs app's `global.css`
/// uses for the same example frame and logo, and the [container] utility —
/// which render as written.
final class ClassName {
  /// A class rendered as written, because another file knows it by name.
  const ClassName.shared(this._local) : _scope = null;

  const ClassName._(this._local, this._scope);

  final String _local;
  final ClassScope<Object?>? _scope;

  /// The class as it appears in the page: the `classes:` value.
  String get name => switch (_scope) {
    null => _local,
    final scope => '$_local-${scope.suffix}',
  };

  /// This class in a selector: `.name`. For a [+] combination, `.a.b`: an
  /// element that carries both.
  String get selector => '.${name.replaceAll(' ', '.')}';

  /// This class and [other] on the same element: `a b` as a `classes:` value.
  ClassName operator +(ClassName other) =>
      ClassName.shared('$name ${other.name}');

  @override
  String toString() => name;
}

/// Centers the content column: `min(100% - 2.5rem, var(--af-container))`
/// wide. The one class any component may put on an element of its own.
const container = ClassName.shared('af-container');

// ---------- Tokens ----------
//
// The palette and metrics are CSS custom properties: light on `:root`, dark
// where `<html>` carries the `dark` class. The values below are the variables;
// the definitions sit in [styles], the colors written from [afLight] and
// [afDark].

const bgColor = Color.variable('--af-bg');
const bg2Color = Color.variable('--af-bg-2');
const surfaceColor = Color.variable('--af-surface');
const surface2Color = Color.variable('--af-surface-2');
const borderColor = Color.variable('--af-border');
const border2Color = Color.variable('--af-border-2');
const textColor = Color.variable('--af-text');
const text2Color = Color.variable('--af-text-2');
const mutedColor = Color.variable('--af-muted');
const accentColor = Color.variable('--af-accent');
const accentInkColor = Color.variable('--af-accent-ink');

/// The primary button's hover fill.
const accentHoverColor = Color.variable('--af-accent-hover');

/// The accent as text: the accent itself on dark, a readable olive on light.
const accentTextColor = Color.variable('--af-accent-text');
const accentSoftColor = Color.variable('--af-accent-soft');
const dangerColor = Color.variable('--af-danger');
const okColor = Color.variable('--af-ok');

const fontSans = FontFamily.variable('--font-sans');
const fontMono = FontFamily.variable('--font-mono');

const radius = Unit.variable('--af-radius');
const headerHeight = Unit.variable('--af-header-h');

/// `var(--af-shadow)`, for the `box-shadow` slot of a `raw` map: `BoxShadow`
/// has no variable form.
const shadow = 'var(--af-shadow)';

/// Marks a link inside running text by more than its colour: underlined in
/// the border colour, a little below the baseline.
const underlinedLink = {
  'text-decoration': 'underline',
  'text-decoration-color': 'var(--af-border-2)',
  'text-underline-offset': '3px',
};

/// A 1px solid border in [color].
Border hairline(Color color) => Border.all(color: color, width: 1.px);

/// One side of a [hairline], for `Border.only`.
BorderSide hairlineSide(Color color) => BorderSide(color: color, width: 1.px);

/// `color-mix(in srgb, <color> <percent>%, <with>)`: [color] at [percent]
/// opacity over [with], which defaults to transparent. Jaspr has no typed form,
/// so it goes into `raw` maps.
String colorMix(Color color, int percent, {Color? with_}) =>
    'color-mix(in srgb, ${color.value} $percent%, '
    '${with_?.value ?? 'transparent'})';

/// Everything the page needs before any component draws: fonts, tokens, the
/// reset, the container and the motion preference.
@css
List<StyleRule> get styles => [
  ..._fonts,
  ..._tokens,
  ..._reset,
  css(container.selector).styles(
    width: const .expression('min(100% - 2.5rem, var(--af-container))'),
    raw: {'margin-inline': 'auto'},
  ),
  ..._motion,
];

// ---------- Fonts ----------

const _latin =
    'U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, '
    'U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, '
    'U+2212, U+2215, U+FEFF, U+FFFD';
const _latinExt =
    'U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF, U+0304, '
    'U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF, U+2020, '
    'U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF';

/// The two variable fonts, self-hosted from `web/fonts/` (SIL Open Font
/// License, the texts sit alongside the files), so no third-party stylesheet
/// blocks the first paint. Latin and Latin Extended subsets cover the site's
/// text; `swap` shows the fallback stack until they arrive, and the `<head>`
/// preloads the Latin two.
List<StyleRule> get _fonts => [
  _fontFace('Space Grotesk', '300 700', 'space-grotesk-latin', _latin),
  _fontFace('Space Grotesk', '300 700', 'space-grotesk-latin-ext', _latinExt),
  _fontFace('JetBrains Mono', '100 800', 'jetbrains-mono-latin', _latin),
  _fontFace('JetBrains Mono', '100 800', 'jetbrains-mono-latin-ext', _latinExt),
];

/// One `@font-face`. Jaspr's `css.fontFace` knows neither weight ranges,
/// `font-display` nor `unicode-range`, so the at-rule is spelled out: `css()`
/// takes any selector text, and an at-rule with a declaration block renders
/// the same way a rule does.
StyleRule _fontFace(String family, String weights, String file, String range) =>
    css('@font-face').styles(
      raw: {
        'font-family': '"$family"',
        'font-style': 'normal',
        'font-weight': weights,
        'font-display': 'swap',
        'src': 'url("/fonts/$file.woff2") format("woff2")',
        'unicode-range': range,
      },
    );

// ---------- Tokens ----------

/// A theme's `--af-*` colors as declarations, for a `raw` map.
Map<String, String> _colors(AfTheme theme) => {
  for (final MapEntry(:key, :value) in theme.cssVariables.entries)
    key: value.value,
};

List<StyleRule> get _tokens => [
  css(':root').styles(
    raw: {
      ..._colors(afLight),
      '--af-shadow': '0 24px 60px -32px rgba(0, 0, 0, 0.25)',
      '--af-radius': '14px',
      '--af-header-h': '3.5rem',
      '--af-container': '1160px',
      '--font-sans':
          '"Space Grotesk", ui-sans-serif, system-ui, -apple-system, '
          '"Segoe UI", Roboto, sans-serif',
      '--font-mono':
          '"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Consolas, '
          'monospace',
      // Code tokens: GitHub Light.
      '--tk-keyword': '#cf222e',
      '--tk-type': '#953800',
      '--tk-string': '#0a3069',
      '--tk-number': '#0550ae',
      '--tk-comment': '#656d76',
      '--tk-annotation': '#8250df',
      '--tk-function': '#8250df',
      '--tk-operator': '#0550ae',
      'color-scheme': 'light',
    },
  ),
  css('.dark').styles(
    raw: {
      ..._colors(afDark),
      '--af-shadow': '0 24px 60px -32px rgba(0, 0, 0, 0.9)',
      // Code tokens: Material Palenight.
      '--tk-keyword': '#c792ea',
      '--tk-type': '#ffcb6b',
      '--tk-string': '#c3e88d',
      '--tk-number': '#f78c6c',
      '--tk-comment': '#767eaa',
      '--tk-annotation': '#ffcb6b',
      '--tk-function': '#82aaff',
      '--tk-operator': '#89ddff',
      'color-scheme': 'dark',
    },
  ),
];

// ---------- Base ----------

List<StyleRule> get _reset => [
  css('*, *::before, *::after').styles(boxSizing: .borderBox),
  css('html').styles(
    raw: {
      'scroll-behavior': 'smooth',
      'scroll-padding-top': 'calc(var(--af-header-h) + 16px)',
      '-webkit-text-size-adjust': '100%',
      'scrollbar-gutter': 'stable',
    },
  ),
  css('body').styles(
    margin: .zero,
    color: textColor,
    fontFamily: fontSans,
    fontSize: 1.0625.rem,
    lineHeight: const .expression('1.6'),
    backgroundColor: bgColor,
    raw: {
      '-webkit-font-smoothing': 'antialiased',
      'text-rendering': 'optimizeLegibility',
    },
  ),
  css('h1, h2, h3').styles(
    margin: .zero,
    fontWeight: .w600,
    letterSpacing: (-0.02).em,
    lineHeight: const .expression('1.15'),
    raw: {'text-wrap': 'balance'},
  ),
  css('p').styles(margin: .zero),
  css('a').styles(color: .inherit, textDecoration: .none),
  css('ul, ol').styles(padding: .zero, margin: .zero, listStyle: .none),
  css('button').styles(
    padding: .zero,
    cursor: .pointer,
    color: .inherit,
    raw: {'font': 'inherit', 'background': 'none', 'border': '0'},
  ),
  css('svg').styles(
    display: .inlineBlock,
    flex: .none,
    raw: {'vertical-align': 'middle'},
  ),
  css(
    'code, pre, kbd',
  ).styles(fontFamily: fontMono, raw: {'font-feature-settings': '"liga" 0'}),
  // Inline code chips.
  css('p code, li code, h3 code').styles(
    padding: .symmetric(vertical: 0.1.em, horizontal: 0.4.em),
    border: hairline(borderColor),
    radius: .circular(6.px),
    color: textColor,
    fontSize: 0.85.em,
    whiteSpace: .noWrap,
    backgroundColor: surface2Color,
  ),
  css(':focus-visible').styles(
    radius: .circular(4.px),
    outline: Outline(
      color: accentTextColor,
      style: .solid,
      width: OutlineWidth(2.px),
      offset: 3.px,
    ),
  ),
  css(
    '::selection',
  ).styles(color: accentInkColor, backgroundColor: accentColor),
];

// ---------- Motion ----------

List<StyleRule> get _motion => [
  // The live dot in the hero and the "attaching" status of an example frame.
  css.keyframes('af-pulse', {'50%': const Styles(opacity: 0.3)}),
  // Motion is a garnish here; readers who asked for less of it get none.
  css.media(const MediaQuery.raw('(prefers-reduced-motion: reduce)'), [
    css('html').styles(raw: {'scroll-behavior': 'auto'}),
    css('*, *::before, *::after').styles(
      raw: {
        'animation-duration': '0.01ms !important',
        'animation-iteration-count': '1 !important',
        'transition-duration': '0.01ms !important',
      },
    ),
  ]),
];
