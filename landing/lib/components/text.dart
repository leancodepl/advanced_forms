import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
