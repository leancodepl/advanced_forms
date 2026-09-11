import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

part 'section.scopes.dart';

/// A landing-page section: full-bleed padding, a hairline on top, the content
/// column, and the shared header of an [Eyebrow], a heading and a [Lead].
///
/// Every section gets an `id` for in-page anchors and an `aria-labelledby`
/// pointing at its heading, so the outline reads well for crawlers and screen
/// readers alike.
@scopedCss
class Section extends StatelessComponent {
  const Section({
    required String this.id,
    required String this.eyebrow,
    required List<Component> this.heading,
    required this.children,
    this.lead,
    super.key,
  }) : _labelledBy = null;

  /// A section without the shared header: [children] go straight into the
  /// content column, and [labelledBy] is the id of the heading among them.
  const Section.plain({
    required String labelledBy,
    required this.children,
    this.id,
    super.key,
  }) : eyebrow = null,
       heading = null,
       lead = null,
       _labelledBy = labelledBy;

  final String? id;
  final String? eyebrow;
  final List<Component>? heading;
  final List<Component>? lead;
  final List<Component> children;
  final String? _labelledBy;

  static const _class = _$sectionScope;
  static final _section = _class('af-section');
  static final _head = _class('af-section-head');

  @css
  static List<StyleRule> get styles => [
    css(_section.selector).styles(
      padding: const .symmetric(
        vertical: .expression('clamp(3.5rem, 7vw, 6rem)'),
        horizontal: .zero,
      ),
      border: .only(top: hairlineSide(borderColor)),
    ),
    css(
      '${_section.selector} h2',
    ).styles(fontSize: const .expression('clamp(1.9rem, 3.6vw, 2.75rem)')),
    css(_head.selector).styles(
      maxWidth: 44.rem,
      margin: .only(bottom: 2.5.rem),
    ),
  ];

  @override
  Component build(BuildContext context) {
    final headingId = _labelledBy ?? '$id-heading';
    return section(
      id: id,
      classes: _section.name,
      attributes: {'aria-labelledby': headingId},
      [
        div(classes: container.name, [
          if ((eyebrow, heading) case (final eyebrow?, final heading?))
            header(classes: _head.name, [
              Eyebrow(eyebrow),
              h2(id: headingId, heading),
              if (lead case final lead?) Lead(lead),
            ]),
          ...children,
        ]),
      ],
    );
  }
}

/// The small mono line above a heading, with a short accent rule before it.
@scopedCss
class Eyebrow extends StatelessComponent {
  const Eyebrow(this.text, {super.key});

  final String text;

  static const _class = _$eyebrowScope;
  static final _eyebrow = _class('af-eyebrow');

  @css
  static List<StyleRule> get styles => [
    css(_eyebrow.selector).styles(
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
    css('${_eyebrow.selector}::before').styles(
      content: '',
      width: 1.5.rem,
      height: 2.px,
      backgroundColor: accentColor,
    ),
  ];

  @override
  Component build(BuildContext context) =>
      p(classes: _eyebrow.name, [.text(text)]);
}

/// The paragraph under a heading that says what the section is about.
@scopedCss
class Lead extends StatelessComponent {
  const Lead(this.children, {super.key});

  final List<Component> children;

  static const _class = _$leadScope;
  static final _lead = _class('af-lead');

  @css
  static List<StyleRule> get styles => [
    css(_lead.selector).styles(
      margin: .only(top: 1.rem),
      color: text2Color,
      fontSize: 1.125.rem,
    ),
  ];

  @override
  Component build(BuildContext context) => p(classes: _lead.name, children);
}

/// A "read more" line under a section's content: one link into the docs.
@scopedCss
class MoreLink extends StatelessComponent {
  const MoreLink(this.text, {required this.href, super.key});

  final String text;
  final String href;

  static const _class = _$moreLinkScope;
  static final _more = _class('af-section-more');

  @css
  static List<StyleRule> get styles => [
    css(_more.selector).styles(
      margin: .only(top: 1.5.rem),
      fontWeight: .w500,
    ),
    css('${_more.selector} a').styles(color: accentTextColor),
    css(
      '${_more.selector} a:hover',
    ).styles(textDecoration: const TextDecoration(line: .underline)),
  ];

  @override
  Component build(BuildContext context) => p(classes: _more.name, [
    a(href: href, [.text(text)]),
  ]);
}

/// Room above a live demo that follows other content in a section.
@scopedCss
class DemoSlot extends StatelessComponent {
  const DemoSlot(this.child, {super.key});

  final Component child;

  static const _class = _$demoSlotScope;
  static final _demo = _class('af-section-demo');

  @css
  static List<StyleRule> get styles => [
    css(_demo.selector).styles(margin: .only(top: 2.5.rem)),
  ];

  @override
  Component build(BuildContext context) => div(classes: _demo.name, [child]);
}

/// The points under a demo, each led by a short accent dash: bold claim first,
/// then the sentence that backs it.
@scopedCss
class Checklist extends StatelessComponent {
  const Checklist(this.items, {super.key});

  /// One entry per item; the entry's components become the `<li>`.
  final List<List<Component>> items;

  static const _class = _$checklistScope;
  static final _list = _class('af-checklist');

  @css
  static List<StyleRule> get styles => [
    css(_list.selector).styles(
      display: .grid,
      maxWidth: 52.rem,
      margin: .only(top: 2.rem),
      gap: .all(0.75.rem),
    ),
    css('${_list.selector} li').styles(
      position: const .relative(),
      padding: .only(left: 1.6.rem),
      color: text2Color,
    ),
    css(
      '${_list.selector} li strong',
    ).styles(color: textColor, fontWeight: .w600),
    css('${_list.selector} li::before').styles(
      content: '',
      position: .absolute(top: 0.7.em, left: .zero),
      width: 0.9.rem,
      height: 2.px,
      backgroundColor: accentColor,
    ),
  ];

  @override
  Component build(BuildContext context) =>
      ul(classes: _list.name, [for (final item in items) li(item)]);
}
