import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A small rounded badge: a version, a licence, a promise. With [href] it
/// links out; [accent] draws it in the accent colour.
class Pill extends StatelessComponent {
  const Pill(this.text, {this.href, this.accent = false, super.key});

  final String text;
  final String? href;
  final bool accent;

  @css
  static List<StyleRule> get styles => [
    css('.af-pill').styles(
      display: .inlineFlex,
      padding: .symmetric(vertical: 0.3.rem, horizontal: 0.7.rem),
      border: hairline(border2Color),
      radius: .circular(999.px),
      alignItems: .center,
      gap: .all(0.35.rem),
      color: text2Color,
      fontSize: 0.8.rem,
      fontWeight: .w500,
      whiteSpace: .noWrap,
      raw: {'background': colorMix(textColor, 4)},
    ),
    css('.af-pill-accent').styles(
      color: accentTextColor,
      backgroundColor: accentSoftColor,
      raw: {'border-color': colorMix(accentColor, 45, with_: border2Color)},
    ),
    css(
      'a.af-pill-accent:hover',
    ).styles(raw: {'border-color': accentColor.value}),
  ];

  @override
  Component build(BuildContext context) {
    final classes = accent ? 'af-pill af-pill-accent' : 'af-pill';
    if (href case final href?) {
      return externalLink(href, classes: classes, [.text(text)]);
    }
    return span(classes: classes, [.text(text)]);
  }
}
