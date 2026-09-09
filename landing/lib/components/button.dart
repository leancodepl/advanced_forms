import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// How a [Button] is filled.
enum ButtonVariant {
  /// Accent fill with dark text: the one action a section wants taken.
  primary,

  /// Surface fill with a hairline: the alternative next to a primary button.
  secondary,
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

  @css
  static List<StyleRule> get styles => [
    css('.af-button').styles(
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
    css('.af-button:hover').styles(transform: .translate(y: (-1).px)),
    css(
      '.af-button-primary',
    ).styles(color: accentInkColor, backgroundColor: accentColor),
    css('.af-button-primary:hover').styles(backgroundColor: accentHoverColor),
    css('.af-button-secondary').styles(
      color: textColor,
      backgroundColor: surfaceColor,
      raw: {'border-color': border2Color.value},
    ),
    css(
      '.af-button-secondary:hover',
    ).styles(raw: {'border-color': accentColor.value}),
  ];

  @override
  Component build(BuildContext context) {
    final classes = 'af-button af-button-${variant.name}';
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
