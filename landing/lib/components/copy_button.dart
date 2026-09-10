import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// How a [CopyButton] looks.
enum CopyButtonVariant {
  /// A framed button with a label, sitting in a command line.
  framed(ClassName('af-copy-framed', owner: CopyButton)),

  /// A square, icon-only button that fills on hover, for a toolbar.
  ghost(ClassName('af-copy-ghost', owner: CopyButton));

  const CopyButtonVariant(this.className);

  final ClassName className;
}

/// A button that copies text to the clipboard and shows a check mark for a
/// moment afterwards. `web/landing.js` wires the click and flashes the
/// `data-copied` attribute the styles below react to.
class CopyButton extends StatelessComponent {
  /// Copies [text].
  const CopyButton({
    required String text,
    required this.ariaLabel,
    this.variant = .framed,
    this.label,
    this.title,
    super.key,
  }) : _text = text;

  /// Copies the source file the enclosing example frame currently shows;
  /// `landing.js` finds it from the checked file tab.
  const CopyButton.sourceFile({
    required this.ariaLabel,
    this.variant = .ghost,
    this.label,
    this.title,
    super.key,
  }) : _text = null;

  final String? _text;
  final String ariaLabel;
  final CopyButtonVariant variant;

  /// A visible label after the icon.
  final String? label;

  /// A tooltip.
  final String? title;

  /// The button itself.
  static const className = ClassName('af-copy-button', owner: CopyButton);

  /// The visible [label], for a rule that hides it where the room is short.
  static const labelClassName = ClassName('af-copy-label', owner: CopyButton);

  static const _idle = ClassName('af-copy-idle', owner: CopyButton);
  static const _done = ClassName('af-copy-done', owner: CopyButton);

  @css
  static List<StyleRule> get styles => [
    css(className.selector).styles(
      display: .inlineFlex,
      transition: .combine([
        Transition('color', duration: 150.ms, curve: .ease),
        Transition('border-color', duration: 150.ms, curve: .ease),
      ]),
      alignItems: .center,
    ),
    css(CopyButtonVariant.framed.className.selector).styles(
      padding: .symmetric(vertical: 0.45.rem, horizontal: 0.75.rem),
      border: hairline(border2Color),
      radius: .circular(8.px),
      gap: .all(0.4.rem),
      color: text2Color,
      backgroundColor: surfaceColor,
      raw: {'font': '600 0.78rem/1 var(--font-sans)'},
    ),
    css(
      '${CopyButtonVariant.framed.className.selector}:hover',
    ).styles(color: textColor, raw: {'border-color': accentColor.value}),
    css(CopyButtonVariant.ghost.className.selector).styles(
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
      '${CopyButtonVariant.ghost.className.selector}:hover',
    ).styles(color: textColor, backgroundColor: surface2Color),
    // The icons sit in flex spans, so no line box adds slack around them.
    css('${_idle.selector}, ${_done.selector}').styles(display: .inlineFlex),
    // Copied: the check mark replaces the icon and the button turns green.
    // Last, so it wins over the hover rules of either variant.
    css(_done.selector).styles(display: .none, color: okColor),
    css(
      '${className.selector}[data-copied="true"]',
    ).styles(color: okColor, raw: {'border-color': okColor.value}),
    css(
      '${className.selector}[data-copied="true"] ${_idle.selector}',
    ).styles(display: .none),
    css(
      '${className.selector}[data-copied="true"] ${_done.selector}',
    ).styles(display: .inlineFlex),
  ];

  @override
  Component build(BuildContext context) {
    return button(
      classes: (className + variant.className).name,
      attributes: {
        'type': 'button',
        if (_text case final text?) 'data-copy-text': text else 'data-copy': '',
        'aria-label': ariaLabel,
        'aria-live': 'polite',
        'title': ?title,
      },
      [
        span(classes: _idle.name, [Icon.copy.build(size: 15)]),
        span(classes: _done.name, [Icon.check.build(size: 15)]),
        if (label case final label?)
          span(classes: labelClassName.name, [.text(label)]),
      ],
    );
  }
}
