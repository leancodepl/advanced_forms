import 'package:advanced_forms_landing/components/copy_button.dart';
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
///
/// The class names are a contract with two other files. `landing.js` looks up
/// the example, its stage, status, code, tab inputs and code panels, and puts
/// the notice, the gate and its "done" badge on the stage. The docs app draws
/// the same frame around its own examples in `global.css`, under the same
/// names, so the two sites read as one.
class ExampleFrame extends StatelessComponent {
  const ExampleFrame({required this.example, required this.layout, super.key});

  final LandingExample example;
  final ExampleLayout layout;

  static const _example = ClassName('af-example');
  static const _bar = ClassName('af-example-bar');
  static const _dots = ClassName('af-dots');
  static const _title = ClassName('af-example-title');
  static const _status = ClassName('af-example-status');
  static const _body = ClassName('af-example-body');
  static const _stage = ClassName('af-example-stage');
  static const _notice = ClassName('af-example-notice');
  static const _gate = ClassName('af-example-gate');
  static const _gateDone = ClassName('af-example-gate-done');
  static const _caption = ClassName('af-example-caption');
  static const _code = ClassName('af-example-code');
  static const _toolbar = ClassName('af-example-toolbar');
  static const _tabs = ClassName('af-example-tabs');
  static const _tabInput = ClassName('af-tab-input');
  static const _tab = ClassName('af-example-tab');
  static const _panels = ClassName('af-example-panels');
  static const _panel = ClassName('af-code-panel');

  static String _split(ClassName part) =>
      '${_example.selector}[data-layout="split"] ${part.selector}';

  @css
  static List<StyleRule> get styles => [
    ..._frame,
    ..._stageRules,
    ..._source,
    ..._tabRules,
    ..._panelRules,
    css.media(MediaQuery.all(minWidth: 960.px), [
      css(_split(_body)).styles(
        display: .grid,
        raw: {
          'grid-template-columns': 'minmax(0, 1.15fr) minmax(0, 1fr)',
          'align-items': 'start',
        },
      ),
      css(_split(_stage)).styles(
        position: const .sticky(
          top: .expression('calc(var(--af-header-h) + 1.5rem)'),
        ),
        border: .only(left: hairlineSide(borderColor)),
        order: 2,
      ),
      css(_split(_code)).styles(padding: .all(0.75.rem), order: 1),
    ]),
  ];

  /// The window: title bar with dots, title and the island's status.
  static List<StyleRule> get _frame => [
    css(_example.selector).styles(
      margin: .zero,
      border: hairline(borderColor),
      radius: const .circular(radius),
      overflow: .hidden,
      backgroundColor: surfaceColor,
      raw: {'box-shadow': shadow},
    ),
    css(_bar.selector).styles(
      display: .flex,
      minHeight: 2.6.rem,
      padding: .fromLTRB(0.9.rem, 0.4.rem, 0.75.rem, 0.4.rem),
      border: .only(bottom: hairlineSide(borderColor)),
      alignItems: .center,
      gap: .all(0.75.rem),
      backgroundColor: surface2Color,
    ),
    css(
      _dots.selector,
    ).styles(display: .inlineFlex, gap: .all(0.4.rem), flex: .none),
    css('${_dots.selector} span').styles(
      width: 10.px,
      height: 10.px,
      radius: .circular(50.percent),
      backgroundColor: border2Color,
    ),
    css(
      '${_dots.selector} span:first-child',
    ).styles(backgroundColor: accentColor),
    css(_title.selector).styles(
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
    css(_status.selector).styles(
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
    css('${_status.selector}::before').styles(
      content: '',
      width: 7.px,
      height: 7.px,
      radius: .circular(50.percent),
      backgroundColor: mutedColor,
    ),
    css('${_status.selector}[data-status="ready"]').styles(color: okColor),
    css('${_status.selector}[data-status="ready"]::before').styles(
      backgroundColor: okColor,
      raw: {'box-shadow': '0 0 0 3px ${colorMix(okColor, 25)}'},
    ),
    css('${_status.selector}[data-status="attaching"]::before').styles(
      backgroundColor: accentColor,
      raw: {'animation': 'af-pulse 1s ease-in-out infinite'},
    ),
    css(
      '${_status.selector}[data-status="failed"]::before, '
      '${_status.selector}[data-status="evicted"]::before',
    ).styles(backgroundColor: dangerColor),
    // Either half may hold a wide code sample; let it shrink and scroll
    // instead of stretching the page.
    css('${_body.selector} > *').styles(minWidth: .zero),
  ];

  /// The stage the Flutter view attaches to, and what `landing.js` puts on it
  /// while that has not happened: a notice when it cannot, a gate over a view
  /// that is waiting for a click, and the caption under the source.
  static List<StyleRule> get _stageRules => [
    css(
      _stage.selector,
    ).styles(position: const .relative(), backgroundColor: surfaceColor),
    css('${_stage.selector}[data-settled="false"]').styles(minHeight: 8.rem),
    css(_notice.selector).styles(
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
    css('${_notice.selector} button').styles(
      display: .block,
      padding: .symmetric(vertical: 0.35.rem, horizontal: 0.9.rem),
      margin: .only(top: 0.6.rem, right: .auto, bottom: .zero, left: .auto),
      radius: .circular(999.px),
      color: accentInkColor,
      fontSize: 0.8.rem,
      fontWeight: .w600,
      backgroundColor: accentColor,
    ),
    css(_gate.selector).styles(
      display: .flex,
      position: const .absolute(),
      justifyContent: .center,
      alignItems: .center,
      backdropFilter: .blur(1.px),
      raw: {'inset': '0', 'background': colorMix(surfaceColor, 55)},
    ),
    css('${_gate.selector} span').styles(
      padding: .symmetric(vertical: 0.45.rem, horizontal: 1.1.rem),
      radius: .circular(999.px),
      color: accentInkColor,
      fontSize: 0.875.rem,
      fontWeight: .w600,
      backgroundColor: accentColor,
    ),
    css(_gateDone.selector).styles(
      position: .absolute(top: 0.35.rem, right: 0.35.rem),
      padding: .symmetric(vertical: 0.15.rem, horizontal: 0.55.rem),
      radius: .circular(6.px),
      color: text2Color,
      fontSize: 0.75.rem,
      backgroundColor: surface2Color,
    ),
    css(_caption.selector).styles(
      padding: .symmetric(vertical: 0.75.rem, horizontal: 0.9.rem),
      border: .only(top: hairlineSide(borderColor)),
      color: mutedColor,
      fontSize: 0.85.rem,
    ),
    css(
      '${_caption.selector} a',
    ).styles(color: text2Color, raw: underlinedLink),
  ];

  /// Source, one file at a time: the toolbar with the tab strip and the copy
  /// button beside it.
  static List<StyleRule> get _source => [
    css(
      _code.selector,
    ).styles(padding: .fromLTRB(0.75.rem, .zero, 0.75.rem, 0.75.rem)),
    // The radio is clipped away; its label is the visible tab.
    css(_tabInput.selector).styles(
      position: const .absolute(),
      width: 1.px,
      height: 1.px,
      margin: .all((-1).px),
      overflow: .hidden,
      opacity: 0,
      raw: {'clip': 'rect(0 0 0 0)'},
    ),
    css(_toolbar.selector).styles(
      display: .flex,
      padding: .fromLTRB(0.35.rem, 0.35.rem, 0.35.rem, .zero),
      alignItems: .center,
      gap: .all(0.25.rem),
    ),
    // The copy button sits beside the strip, not in it, so it stays put when
    // the strip scrolls.
    css(_tabs.selector).styles(
      display: .flex,
      minWidth: .zero,
      overflow: const .only(x: .auto),
      alignItems: .center,
      gap: .all(0.25.rem),
      raw: {'flex': '1', 'scrollbar-width': 'none'},
    ),
  ];

  static List<StyleRule> get _tabRules => [
    css(_tab.selector).styles(
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
    css('${_tab.selector}:hover').styles(color: textColor),
    // The checked radio picks its tab: the label right after it.
    css('${_tabInput.selector}:checked + ${_tab.selector}').styles(
      color: textColor,
      backgroundColor: bg2Color,
      raw: {
        'border-color': borderColor.value,
        'box-shadow': 'inset 0 2px 0 var(--af-accent)',
      },
    ),
    // The radio is clipped away; its label shows the keyboard focus instead.
    css('${_tabInput.selector}:focus-visible + ${_tab.selector}').styles(
      outline: Outline(
        color: accentTextColor,
        style: .solid,
        width: OutlineWidth(2.px),
        offset: (-2).px,
      ),
    ),
  ];

  static List<StyleRule> get _panelRules => [
    css(_panel.selector).styles(
      display: .none,
      margin: .only(top: (-1).px),
      border: hairline(borderColor),
      overflow: .hidden,
      backgroundColor: bg2Color,
      raw: {
        'border-radius': '0 var(--af-radius) var(--af-radius) var(--af-radius)',
      },
    ),
    css('${_panel.selector} pre').styles(
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
    css(
      '${_panel.selector} code',
    ).styles(display: .block, minWidth: .maxContent),
    // The checked radio also picks its panel, for up to eight files.
    css(
      [for (var n = 1; n <= 8; n++) _panelSelector(n)].join(', '),
    ).styles(display: .block),
  ];

  static String _panelSelector(int n) =>
      '${_code.selector}:has(${_tabInput.selector}:nth-of-type($n):checked) '
      '${_panel.selector}:nth-child($n)';

  @override
  Component build(BuildContext context) {
    return figure(
      classes: _example.name,
      attributes: {'data-layout': layout.name},
      [
        div(classes: _bar.name, [
          span(
            classes: _dots.name,
            attributes: const {'aria-hidden': 'true'},
            const [span([]), span([]), span([])],
          ),
          span(classes: _title.name, [.text(example.title)]),
          span(
            classes: _status.name,
            attributes: const {'data-status': 'idle', 'aria-live': 'polite'},
            const [.text('idle')],
          ),
        ]),
        div(classes: _body.name, [
          div(
            classes: _stage.name,
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
          figcaption(classes: _caption.name, const [
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
      classes: ExampleFrame._code.name,
      attributes: const {'data-tabs': 'true'},
      [
        div(classes: ExampleFrame._toolbar.name, [
          // What it is, to assistive technology: a group of radio buttons, one
          // per file, each followed by the label that is its visible tab. The
          // CSS reads the checked one to show its tab and its panel.
          div(
            classes: ExampleFrame._tabs.name,
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
                    'class': ExampleFrame._tabInput.name,
                    'aria-label': file.name,
                    if (index == 0) 'checked': '',
                  },
                ),
                label(
                  classes: ExampleFrame._tab.name,
                  attributes: {'for': '$group-$index'},
                  [.text(file.name)],
                ),
              ],
            ],
          ),
          const CopyButton.sourceFile(
            ariaLabel: 'Copy this file',
            title: 'Copy this file',
          ),
        ]),
        div(classes: ExampleFrame._panels.name, [
          for (final file in example.files)
            div(classes: ExampleFrame._panel.name, [
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
