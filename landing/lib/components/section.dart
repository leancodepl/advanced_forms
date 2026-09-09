import 'package:advanced_forms_landing/styles.dart';
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

  /// The section itself and the vocabulary its children share: the header
  /// (eyebrow, heading, lead), a "read more" line, the demo slot and the
  /// checklist under a demo.
  @css
  static List<StyleRule> get styles => [
    css('.af-section').styles(
      padding: const .symmetric(
        vertical: .expression('clamp(3.5rem, 7vw, 6rem)'),
        horizontal: .zero,
      ),
      border: .only(top: hairlineSide(borderColor)),
    ),
    css('.af-section-head').styles(
      maxWidth: 44.rem,
      margin: .only(bottom: 2.5.rem),
    ),
    css(
      '.af-section h2',
    ).styles(fontSize: const .expression('clamp(1.9rem, 3.6vw, 2.75rem)')),
    css('.af-eyebrow').styles(
      display: .inlineFlex,
      margin: .only(bottom: 1.rem),
      alignItems: .center,
      gap: .all(0.5.rem),
      color: accentTextColor,
      fontFamily: fontMono,
      fontSize: 0.78.rem,
      fontWeight: .w600,
      textTransform: .upperCase,
      letterSpacing: 0.08.em,
    ),
    css('.af-eyebrow::before').styles(
      content: '',
      width: 1.5.rem,
      height: 2.px,
      backgroundColor: accentColor,
    ),
    css('.af-lead').styles(
      margin: .only(top: 1.rem),
      color: text2Color,
      fontSize: 1.125.rem,
    ),
    css('.af-section-more').styles(
      margin: .only(top: 1.5.rem),
      fontWeight: .w500,
    ),
    css('.af-section-more a').styles(color: accentTextColor),
    css(
      '.af-section-more a:hover',
    ).styles(textDecoration: const TextDecoration(line: .underline)),
    css('.af-section-demo').styles(margin: .only(top: 2.5.rem)),
    css('.af-checklist').styles(
      display: .grid,
      maxWidth: 52.rem,
      margin: .only(top: 2.rem),
      gap: .all(0.75.rem),
    ),
    css('.af-checklist li').styles(
      position: const .relative(),
      padding: .only(left: 1.6.rem),
      color: text2Color,
    ),
    css('.af-checklist li strong').styles(color: textColor, fontWeight: .w600),
    css('.af-checklist li::before').styles(
      content: '',
      position: .absolute(top: 0.7.em, left: .zero),
      width: 0.9.rem,
      height: 2.px,
      backgroundColor: accentColor,
    ),
  ];

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
