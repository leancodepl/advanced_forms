import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/highlight.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// How the frame arranges the running example and its source.
enum ExampleLayout {
  /// Only the running example — the hero.
  stage,

  /// Source on the left, one file at a time, the running example on the right.
  split,
}

/// The window around a live example: a title bar with the island's status,
/// the running Flutter view, and the source that produced it.
///
/// The stage is an empty `<div>` carrying the example id; `web/landing.js`
/// attaches a view of the shared Flutter engine to it once it scrolls near,
/// and keeps the status pill honest. File tabs are radio inputs and CSS —
/// no script needed to switch files.
class ExampleFrame extends StatelessComponent {
  const ExampleFrame({required this.example, required this.layout, super.key});

  final LandingExample example;
  final ExampleLayout layout;

  @css
  static List<StyleRule> get styles => [
    ..._frame,
    ..._stage,
    ..._source,
    ..._tabs,
    ..._panels,
    css.media(MediaQuery.all(minWidth: 960.px), [
      css('.af-example[data-layout="split"] .af-example-body').styles(
        display: .grid,
        raw: {
          'grid-template-columns': 'minmax(0, 1.15fr) minmax(0, 1fr)',
          'align-items': 'start',
        },
      ),
      css('.af-example[data-layout="split"] .af-example-stage').styles(
        position: const .sticky(
          top: .expression('calc(var(--af-header-h) + 1.5rem)'),
        ),
        border: .only(left: hairlineSide(borderColor)),
        order: 2,
      ),
      css(
        '.af-example[data-layout="split"] .af-example-code',
      ).styles(padding: .all(0.75.rem), order: 1),
    ]),
  ];

  /// The window: title bar with dots, title and the island's status.
  static List<StyleRule> get _frame => [
    css('.af-example').styles(
      margin: .zero,
      border: hairline(borderColor),
      radius: const .circular(radius),
      overflow: .hidden,
      backgroundColor: surfaceColor,
      raw: {'box-shadow': shadow},
    ),
    css('.af-example-bar').styles(
      display: .flex,
      minHeight: 2.6.rem,
      padding: .fromLTRB(0.9.rem, 0.4.rem, 0.75.rem, 0.4.rem),
      border: .only(bottom: hairlineSide(borderColor)),
      alignItems: .center,
      gap: .all(0.75.rem),
      backgroundColor: surface2Color,
    ),
    css(
      '.af-dots',
    ).styles(display: .inlineFlex, gap: .all(0.4.rem), flex: .none),
    css('.af-dots span').styles(
      width: 10.px,
      height: 10.px,
      radius: .circular(50.percent),
      backgroundColor: border2Color,
    ),
    css('.af-dots span:first-child').styles(backgroundColor: accentColor),
    css('.af-example-title').styles(
      minWidth: .zero,
      overflow: .hidden,
      color: mutedColor,
      textAlign: .center,
      fontFamily: fontMono,
      fontSize: 0.75.rem,
      textOverflow: .ellipsis,
      whiteSpace: .noWrap,
      raw: {'flex': '1'},
    ),
    css('.af-example-status').styles(
      display: .inlineFlex,
      alignItems: .center,
      gap: .all(0.4.rem),
      flex: .none,
      color: mutedColor,
      fontFamily: fontMono,
      fontSize: 0.68.rem,
      fontWeight: .w600,
      textTransform: .upperCase,
      letterSpacing: 0.06.em,
    ),
    css('.af-example-status::before').styles(
      content: '',
      width: 7.px,
      height: 7.px,
      radius: .circular(50.percent),
      backgroundColor: mutedColor,
    ),
    css('.af-example-status[data-status="ready"]').styles(color: okColor),
    css('.af-example-status[data-status="ready"]::before').styles(
      backgroundColor: okColor,
      raw: {'box-shadow': '0 0 0 3px ${colorMix(okColor, 25)}'},
    ),
    css('.af-example-status[data-status="attaching"]::before').styles(
      backgroundColor: accentColor,
      raw: {'animation': 'af-pulse 1s ease-in-out infinite'},
    ),
    css(
      '.af-example-status[data-status="failed"]::before, '
      '.af-example-status[data-status="evicted"]::before',
    ).styles(backgroundColor: dangerColor),
  ];

  /// The stage the Flutter view attaches to, and what `landing.js` puts on it
  /// while that has not happened: a notice when it cannot, a gate over a view
  /// that is waiting for a click, and the caption under the source.
  static List<StyleRule> get _stage => [
    css(
      '.af-example-stage',
    ).styles(position: const .relative(), backgroundColor: surfaceColor),
    css('.af-example-stage[data-settled="false"]').styles(minHeight: 8.rem),
    css('.af-example-notice').styles(
      display: .flex,
      position: const .absolute(),
      padding: .all(1.rem),
      justifyContent: .center,
      alignItems: .center,
      color: mutedColor,
      textAlign: .center,
      fontSize: 0.8.rem,
      raw: {'inset': '0'},
    ),
    css('.af-example-notice button').styles(
      display: .block,
      padding: .symmetric(vertical: 0.35.rem, horizontal: 0.9.rem),
      margin: .only(top: 0.6.rem, right: .auto, bottom: .zero, left: .auto),
      radius: .circular(999.px),
      color: accentInkColor,
      fontSize: 0.8.rem,
      fontWeight: .w600,
      backgroundColor: accentColor,
    ),
    css('.af-example-gate').styles(
      display: .flex,
      position: const .absolute(),
      justifyContent: .center,
      alignItems: .center,
      backdropFilter: .blur(1.px),
      raw: {'inset': '0', 'background': colorMix(surfaceColor, 55)},
    ),
    css('.af-example-gate span').styles(
      padding: .symmetric(vertical: 0.45.rem, horizontal: 1.1.rem),
      radius: .circular(999.px),
      color: accentInkColor,
      fontSize: 0.875.rem,
      fontWeight: .w600,
      backgroundColor: accentColor,
    ),
    css('.af-example-gate-done').styles(
      position: .absolute(top: 0.35.rem, right: 0.35.rem),
      padding: .symmetric(vertical: 0.15.rem, horizontal: 0.55.rem),
      radius: .circular(6.px),
      color: text2Color,
      fontSize: 0.75.rem,
      backgroundColor: surface2Color,
    ),
    css('.af-example-caption').styles(
      padding: .symmetric(vertical: 0.75.rem, horizontal: 0.9.rem),
      border: .only(top: hairlineSide(borderColor)),
      color: mutedColor,
      fontSize: 0.85.rem,
    ),
    css('.af-example-caption a').styles(color: text2Color, raw: underlinedLink),
  ];

  /// Source, one file at a time: the toolbar with the tab strip and the copy
  /// button beside it.
  static List<StyleRule> get _source => [
    css(
      '.af-example-code',
    ).styles(padding: .fromLTRB(0.75.rem, .zero, 0.75.rem, 0.75.rem)),
    // The radio is clipped away; its label is the visible tab.
    css('.af-tab-input').styles(
      position: const .absolute(),
      width: 1.px,
      height: 1.px,
      margin: .all((-1).px),
      overflow: .hidden,
      opacity: 0,
      raw: {'clip': 'rect(0 0 0 0)'},
    ),
    css('.af-example-toolbar').styles(
      display: .flex,
      padding: .fromLTRB(0.35.rem, 0.35.rem, 0.35.rem, .zero),
      alignItems: .center,
      gap: .all(0.25.rem),
    ),
    css('.af-example-tabs').styles(
      display: .flex,
      minWidth: .zero,
      overflow: const .only(x: .auto),
      alignItems: .center,
      gap: .all(0.25.rem),
      raw: {'flex': '1', 'scrollbar-width': 'none'},
    ),
    // Beside the tab strip, not in it, so it stays put when the strip scrolls.
    css('.af-example-copy').styles(
      display: .inlineGrid,
      width: 30.px,
      height: 30.px,
      radius: .circular(6.px),
      flex: .none,
      color: mutedColor,
      backgroundColor: surfaceColor,
      raw: {'place-items': 'center'},
    ),
    css(
      '.af-example-copy:hover',
    ).styles(color: textColor, backgroundColor: surface2Color),
    css(
      '.af-example-copy .af-copy-idle, .af-example-copy .af-copy-done',
    ).styles(display: .none),
    css('.af-example-copy .af-copy-idle').styles(display: .inlineFlex),
    css(
      '.af-example-copy[data-copied="true"] .af-copy-idle',
    ).styles(display: .none),
    css(
      '.af-example-copy[data-copied="true"] .af-copy-done',
    ).styles(display: .inlineFlex),
  ];

  static List<StyleRule> get _tabs => [
    css('.af-example-tab').styles(
      padding: .symmetric(vertical: 0.45.rem, horizontal: 0.8.rem),
      border: hairline(const Color('transparent')),
      cursor: .pointer,
      transition: .combine([
        Transition('color', duration: 150.ms, curve: .ease),
        Transition('background-color', duration: 150.ms, curve: .ease),
      ]),
      flex: .none,
      color: mutedColor,
      fontFamily: fontMono,
      fontSize: 0.75.rem,
      whiteSpace: .noWrap,
      raw: {'border-bottom': '0', 'border-radius': '8px 8px 0 0'},
    ),
    css('.af-example-tab:hover').styles(color: textColor),
    // The checked radio picks its tab: the label right after it.
    css('.af-tab-input:checked + .af-example-tab').styles(
      color: textColor,
      backgroundColor: bg2Color,
      raw: {
        'border-color': borderColor.value,
        'box-shadow': 'inset 0 2px 0 var(--af-accent)',
      },
    ),
    // The radio is clipped away; its label shows the keyboard focus instead.
    css('.af-tab-input:focus-visible + .af-example-tab').styles(
      outline: Outline(
        color: accentTextColor,
        style: .solid,
        width: OutlineWidth(2.px),
        offset: (-2).px,
      ),
    ),
  ];

  static List<StyleRule> get _panels => [
    css('.af-code-panel').styles(
      display: .none,
      margin: .only(top: (-1).px),
      border: hairline(borderColor),
      overflow: .hidden,
      backgroundColor: bg2Color,
      raw: {
        'border-radius': '0 var(--af-radius) var(--af-radius) var(--af-radius)',
      },
    ),
    css('.af-code-panel pre').styles(
      maxHeight: 420.px,
      padding: .symmetric(vertical: 0.9.rem, horizontal: 1.rem),
      margin: .zero,
      overflow: .auto,
      fontSize: 0.8125.rem,
      lineHeight: const .expression('1.65'),
      raw: {
        'tab-size': '2',
        'scrollbar-width': 'thin',
        'scrollbar-color': 'var(--af-border-2) transparent',
      },
    ),
    css('.af-code-panel code').styles(display: .block, minWidth: .maxContent),
    // The checked radio also picks its panel, for up to eight files.
    css(
      [for (var n = 1; n <= 8; n++) _panelSelector(n)].join(', '),
    ).styles(display: .block),
  ];

  static String _panelSelector(int n) =>
      '.af-example-code:has(.af-tab-input:nth-of-type($n):checked) '
      '.af-code-panel:nth-child($n)';

  @override
  Component build(BuildContext context) {
    return figure(
      classes: 'af-example',
      attributes: {'data-layout': layout.name},
      [
        div(classes: 'af-example-bar', [
          const span(
            classes: 'af-dots',
            attributes: {'aria-hidden': 'true'},
            [span([]), span([]), span([])],
          ),
          span(classes: 'af-example-title', [.text(example.title)]),
          const span(
            classes: 'af-example-status',
            attributes: {'data-status': 'idle', 'aria-live': 'polite'},
            [.text('idle')],
          ),
        ]),
        div(classes: 'af-example-body', [
          div(
            classes: 'af-example-stage',
            attributes: {
              'data-example-id': example.id,
              'data-settled': 'false',
              'role': 'group',
              'aria-label': 'Live example: ${example.preview}',
            },
            const [],
          ),
          if (layout == ExampleLayout.split) _SourceTabs(example: example),
        ]),
        if (layout == ExampleLayout.split)
          const figcaption(classes: 'af-example-caption', [
            .text(
              'Field widgets prefixed Docs are shorthands the documentation '
              'defines, not part of the package. ',
            ),
            a(href: '$docsPath/rendering', [.text('Rendering fields')]),
            .text(' shows the widget code an app writes.'),
          ]),
      ],
    );
  }
}

class _SourceTabs extends StatelessComponent {
  const _SourceTabs({required this.example});

  final LandingExample example;

  @override
  Component build(BuildContext context) {
    final group = 'tabs-${example.id}';
    return div(
      classes: 'af-example-code',
      attributes: const {'data-tabs': 'true'},
      [
        div(classes: 'af-example-toolbar', [
          // What it is, to assistive technology: a group of radio buttons, one
          // per file, each followed by the label that is its visible tab. The
          // CSS reads the checked one to show its tab and its panel.
          div(
            classes: 'af-example-tabs',
            attributes: const {
              'role': 'radiogroup',
              'aria-label': 'Source files',
            },
            [
              for (final (index, file) in example.files.indexed) ...[
                Component.element(
                  tag: 'input',
                  attributes: {
                    'type': 'radio',
                    'name': group,
                    'id': '$group-$index',
                    'class': 'af-tab-input',
                    'aria-label': file.name,
                    if (index == 0) 'checked': '',
                  },
                ),
                label(
                  classes: 'af-example-tab',
                  attributes: {'for': '$group-$index'},
                  [.text(file.name)],
                ),
              ],
            ],
          ),
          button(
            classes: 'af-example-copy',
            attributes: const {
              'type': 'button',
              'data-copy': '',
              'aria-label': 'Copy this file',
              'title': 'Copy this file',
            },
            [
              span(classes: 'af-copy-idle', [Icon.copy.build(size: 15)]),
              span(classes: 'af-copy-done', [Icon.check.build(size: 15)]),
            ],
          ),
        ]),
        div(classes: 'af-example-panels', [
          for (final file in example.files)
            div(classes: 'af-code-panel', [
              pre(
                attributes: const {'tabindex': '0'},
                [code(highlightDart(file.code))],
              ),
            ]),
        ]),
      ],
    );
  }
}
