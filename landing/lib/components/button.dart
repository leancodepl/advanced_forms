import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// How a [Button] is filled.
enum ButtonVariant {
  /// Accent fill with dark text: the one action a section wants taken.
  primary,

  /// Surface fill with a hairline: the alternative next to a primary button.
  secondary,
}

/// A pill-shaped call to action that links somewhere, the same component
/// Ciach's site uses. [external] links open in a new tab. An icon can go
/// before the label ([leading]) or after it ([trailing]).
///
/// Styled by `.af-button*` in web/landing.css.
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
