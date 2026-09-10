import 'package:advanced_forms_landing/components/footer.dart';
import 'package:advanced_forms_landing/components/hero.dart';
import 'package:advanced_forms_landing/components/nav_bar.dart';
import 'package:advanced_forms_landing/components/sections.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The landing page: what advanced_forms is, four live demos, where to go next.
class App extends StatelessComponent {
  const App({required this.version, super.key});

  final String version;

  /// `<main>`. The docs' `global.css` knows the name too.
  static const _landing = ClassName('af-landing');
  static const _skipLink = ClassName('af-skip-link');

  @css
  static List<StyleRule> get styles => [
    // Sections may hold wide code samples; let them shrink and scroll instead
    // of stretching the page.
    css('${_landing.selector} > *').styles(minWidth: .zero),
    // Hidden above the viewport until it takes keyboard focus.
    css(_skipLink.selector).styles(
      position: .fixed(top: 12.px, left: 12.px),
      zIndex: const ZIndex(100),
      padding: .symmetric(vertical: 0.6.rem, horizontal: 1.rem),
      radius: .circular(8.px),
      transition: Transition('transform', duration: 200.ms, curve: .ease),
      transform: .translate(y: (-200).percent),
      color: accentInkColor,
      fontWeight: .w600,
      backgroundColor: accentColor,
    ),
    css(
      '${_skipLink.selector}:focus',
    ).styles(transform: const .translate(y: .zero)),
  ];

  @override
  Component build(BuildContext context) {
    return .fragment([
      a(href: '#main', classes: _skipLink.name, const [
        .text('Skip to content'),
      ]),
      const NavBar(),
      Component.element(
        tag: 'main',
        id: 'main',
        classes: _landing.name,
        children: [
          Hero(version: version, demo: loadExample('hero')),
          ModelSection(example: loadExample('signup')),
          ValidationSection(example: loadExample('modes')),
          AsyncSection(example: loadExample('async')),
          const Features(),
          const SkillBand(),
        ],
      ),
      SiteFooter(version: version),
    ]);
  }
}
