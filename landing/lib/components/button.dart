import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/text.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

part 'button.scopes.dart';

/// How a [Button] is filled.
enum ButtonVariant {
  /// Accent fill with dark text: the one action a section wants taken.
  primary('af-button-primary'),

  /// Surface fill with a hairline: the alternative next to a primary button.
  secondary('af-button-secondary');

  const ButtonVariant(this._local);

  /// The class, before [Button] scopes it.
  final String _local;
}

/// A pill-shaped call to action that links somewhere. [external] links open in
/// a new tab. An icon can go before the label ([leading]) or after it
/// ([trailing]).
@scopedCss
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

  static const _class = _$buttonScope;
  static final _button = _class('af-button');

  /// The class of a [variant].
  static ClassName _variantClass(ButtonVariant variant) =>
      _class(variant._local);

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
      _variantClass(.primary).selector,
    ).styles(color: accentInkColor, backgroundColor: accentColor),
    css(
      '${_variantClass(.primary).selector}:hover',
    ).styles(backgroundColor: accentHoverColor),
    css(_variantClass(.secondary).selector).styles(
      color: textColor,
      backgroundColor: surfaceColor,
      raw: {'border-color': border2Color.value},
    ),
    css(
      '${_variantClass(.secondary).selector}:hover',
    ).styles(raw: {'border-color': accentColor.value}),
  ];

  @override
  Component build(BuildContext context) {
    final classes = (_button + _variantClass(variant)).name;
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
@scopedCss
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

  static const _class = _$buttonRowScope;
  static final _row = _class('af-actions');
  static final _center = _class('af-actions-center');
  static final _flush = _class('af-actions-flush');

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
