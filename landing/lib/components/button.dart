import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/text.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// How a [Button] is filled.
enum ButtonVariant {
  /// Accent fill with dark text: the one action a section wants taken.
  primary(ClassName('af-button-primary')),

  /// Surface fill with a hairline: the alternative next to a primary button.
  secondary(ClassName('af-button-secondary'));

  const ButtonVariant(this.className);

  final ClassName className;
}

/// A pill-shaped call to action that links somewhere. [external] links open in
/// a new tab. An icon can go before the label ([leading]) or after it
/// ([trailing]).
class Button extends StatelessComponent {
  const Button(
    this.label, {
    required this.href,
    this.variant = .primary,
    this.external = false,
    this.leading,
    this.trailing,
    super.key,
  });

  final String label;
  final String href;
  final ButtonVariant variant;
  final bool external;
  final Icon? leading;
  final Icon? trailing;

  static const _button = ClassName('af-button');

  @css
  static List<StyleRule> get styles => [
    css(_button.selector).styles(
      display: .inlineFlex,
      padding: .symmetric(vertical: 0.75.rem, horizontal: 1.2.rem),
      border: hairline(const Color('transparent')),
      radius: .circular(999.px),
      cursor: .pointer,
      transition: .combine([
        Transition('transform', duration: 150.ms, curve: .ease),
        Transition('background-color', duration: 150.ms, curve: .ease),
        Transition('border-color', duration: 150.ms, curve: .ease),
        Transition('color', duration: 150.ms, curve: .ease),
      ]),
      alignItems: .center,
      gap: .all(0.5.rem),
      fontSize: 0.95.rem,
      fontWeight: .w600,
      lineHeight: const .expression('1'),
      whiteSpace: .noWrap,
    ),
    css('${_button.selector}:hover').styles(transform: .translate(y: (-1).px)),
    css(
      ButtonVariant.primary.className.selector,
    ).styles(color: accentInkColor, backgroundColor: accentColor),
    css(
      '${ButtonVariant.primary.className.selector}:hover',
    ).styles(backgroundColor: accentHoverColor),
    css(ButtonVariant.secondary.className.selector).styles(
      color: textColor,
      backgroundColor: surfaceColor,
      raw: {'border-color': border2Color.value},
    ),
    css(
      '${ButtonVariant.secondary.className.selector}:hover',
    ).styles(raw: {'border-color': accentColor.value}),
  ];

  @override
  Component build(BuildContext context) {
    final classes = (_button + variant.className).name;
    final children = <Component>[
      if (leading case final icon?) icon.build(size: 18),
      .text(label),
      if (trailing case final icon?) icon.build(size: 18),
    ];
    if (external) {
      return externalLink(href, classes: classes, children);
    }
    return a(href: href, classes: classes, children);
  }
}

/// A wrapping row of [Button]s under a piece of copy.
class ButtonRow extends StatelessComponent {
  const ButtonRow(
    this.children, {
    this.center = false,
    this.flush = false,
    super.key,
  });

  final List<Component> children;

  /// Centered under centered copy, instead of starting at the left edge.
  final bool center;

  /// Without the gap above it, where the row stands on its own.
  final bool flush;

  static const _row = ClassName('af-actions');
  static const _center = ClassName('af-actions-center');
  static const _flush = ClassName('af-actions-flush');

  @css
  static List<StyleRule> get styles => [
    css(_row.selector).styles(
      display: .flex,
      margin: .only(top: 1.75.rem),
      flexWrap: .wrap,
      gap: .all(0.75.rem),
    ),
    css(_center.selector).styles(justifyContent: .center),
    css(_flush.selector).styles(margin: const .only(top: .zero)),
  ];

  @override
  Component build(BuildContext context) {
    var classes = _row;
    if (center) {
      classes += _center;
    }
    if (flush) {
      classes += _flush;
    }
    return div(classes: classes.name, children);
  }
}
