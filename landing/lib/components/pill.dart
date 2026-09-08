import 'package:advanced_forms_landing/components/section.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A small rounded badge: a version, a licence, a promise. With [href] it
/// links out; [accent] draws it in the accent colour.
///
/// Styled by `.af-pill*` in web/landing.css.
class Pill extends StatelessComponent {
  const Pill(this.text, {this.href, this.accent = false, super.key});

  final String text;
  final String? href;
  final bool accent;

  @override
  Component build(BuildContext context) {
    final classes = accent ? 'af-pill af-pill-accent' : 'af-pill';
    if (href case final href?) {
      return externalLink(href, classes: classes, [.text(text)]);
    }
    return span(classes: classes, [.text(text)]);
  }
}
