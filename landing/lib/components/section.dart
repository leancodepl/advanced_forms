import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A landing-page section with the shared eyebrow / heading / lead header.
///
/// Every section gets an `id` for in-page anchors and an `aria-labelledby`
/// pointing at its heading, so the outline reads well for crawlers and screen
/// readers alike.
class Section extends StatelessComponent {
  const Section({
    required this.id,
    required this.eyebrow,
    required this.heading,
    required this.children,
    this.lead,
    super.key,
  });

  final String id;
  final String eyebrow;
  final List<Component> heading;
  final List<Component>? lead;
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    final headingId = '$id-heading';
    return section(
      id: id,
      classes: 'af-section',
      attributes: {'aria-labelledby': headingId},
      [
        div(classes: 'af-container', [
          header(classes: 'af-section-head', [
            p(classes: 'af-eyebrow', [.text(eyebrow)]),
            h2(id: headingId, heading),
            if (lead case final lead?) p(classes: 'af-lead', lead),
          ]),
          ...children,
        ]),
      ],
    );
  }
}

/// Renders [text], turning each backtick-quoted span into an inline `<code>`,
/// so prose data can mention identifiers without hand-built component lists.
List<Component> rich(String text) => [
  for (final (i, part) in text.split('`').indexed)
    if (part.isNotEmpty)
      if (i.isOdd) code([.text(part)]) else .text(part),
];

/// An external link that opens in a new tab with the right `rel`.
Component externalLink(
  String href,
  List<Component> children, {
  String? classes,
  String? label,
}) => a(
  href: href,
  classes: classes,
  attributes: {
    'target': '_blank',
    'rel': 'noopener noreferrer',
    'aria-label': ?label,
  },
  children,
);
