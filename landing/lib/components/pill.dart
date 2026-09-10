import 'package:advanced_forms_landing/components/text.dart';
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

  static const _class = ClassScope<Pill>();
  static final _pill = _class('af-pill');
  static final _accent = _class('af-pill-accent');

  @css
  static List<StyleRule> get styles => [
    css(_pill.selector).styles(
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
    css(_accent.selector).styles(
      color: accentTextColor,
      backgroundColor: accentSoftColor,
      raw: {'border-color': colorMix(accentColor, 45, with_: border2Color)},
    ),
    css(
      'a${_accent.selector}:hover',
    ).styles(raw: {'border-color': accentColor.value}),
  ];

  @override
  Component build(BuildContext context) {
    final classes = (accent ? _pill + _accent : _pill).name;
    if (href case final href?) {
      return externalLink(href, classes: classes, [.text(text)]);
    }
    return span(classes: classes, [.text(text)]);
  }
}
