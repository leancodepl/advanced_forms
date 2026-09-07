import 'package:advanced_forms_landing/components/footer.dart';
import 'package:advanced_forms_landing/components/hero.dart';
import 'package:advanced_forms_landing/components/nav_bar.dart';
import 'package:advanced_forms_landing/components/sections.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The landing page: what advanced_forms is, four live demos, where to go next.
class App extends StatelessComponent {
  const App({required this.version, super.key});

  final String version;

  @override
  Component build(BuildContext context) {
    return .fragment([
      const a(href: '#main', classes: 'af-skip-link', [
        .text('Skip to content'),
      ]),
      const NavBar(),
      Component.element(
        tag: 'main',
        id: 'main',
        classes: 'af-landing',
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
