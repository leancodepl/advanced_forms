import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/logo.dart';
import 'package:advanced_forms_landing/components/text.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The site header: the word mark on the left, the places a visitor can go on
/// the right. The docs are a separate app under `/docs`, served from the same
/// domain, so every item is a plain link.
class NavBar extends StatelessComponent {
  const NavBar({super.key});

  static const _header = ClassName('af-header');
  static const _nav = ClassName('af-nav');
  static const _brand = ClassName('af-brand');
  static const _links = ClassName('af-nav-links');
  static const _secondary = ClassName('af-nav-secondary');
  static const _toggle = ClassName('af-theme-toggle');
  static const _sun = ClassName('af-theme-sun');
  static const _moon = ClassName('af-theme-moon');

  @css
  static List<StyleRule> get styles => [
    css(_header.selector).styles(
      position: const .sticky(top: .zero),
      zIndex: const ZIndex(50),
      height: headerHeight,
      border: .only(bottom: hairlineSide(borderColor)),
      backdropFilter: .list([const .saturate(1.4), .blur(14.px)]),
      raw: {
        'background': colorMix(bgColor, 80),
        '-webkit-backdrop-filter': 'saturate(140%) blur(14px)',
      },
    ),
    css(_nav.selector).styles(
      display: .flex,
      height: 100.percent,
      justifyContent: .spaceBetween,
      alignItems: .center,
      gap: .all(1.rem),
    ),
    css(_brand.selector).styles(display: .inlineFlex, alignItems: .center),
    css(
      _links.selector,
    ).styles(display: .flex, alignItems: .center, gap: .all(0.25.rem)),
    css('${_links.selector} a, ${_toggle.selector}').styles(
      display: .inlineFlex,
      padding: .symmetric(vertical: 0.5.rem, horizontal: 0.85.rem),
      radius: .circular(999.px),
      transition: .combine([
        Transition('background-color', duration: 150.ms, curve: .ease),
        Transition('color', duration: 150.ms, curve: .ease),
      ]),
      alignItems: .center,
      gap: .all(0.45.rem),
      color: text2Color,
      fontSize: 0.95.rem,
      fontWeight: .w500,
    ),
    css(
      '${_links.selector} a:hover, ${_toggle.selector}:hover',
    ).styles(color: textColor, backgroundColor: surface2Color),
    css(_toggle.selector).styles(padding: .all(0.5.rem)),
    // One icon per theme.
    css(_moon.selector).styles(display: .none),
    css('.dark ${_sun.selector}').styles(display: .none),
    css('.dark ${_moon.selector}').styles(display: .inlineFlex),
    css.media(MediaQuery.all(maxWidth: 540.px), [
      css('${_links.selector} a, ${_toggle.selector}').styles(
        padding: .symmetric(vertical: 0.5.rem, horizontal: 0.55.rem),
        fontSize: 0.9.rem,
      ),
      css(_links.selector).styles(gap: const .all(.zero)),
      // Examples is reachable from the docs; the row has to fit next to the
      // logo.
      css(_secondary.selector).styles(display: .none),
    ]),
  ];

  @override
  Component build(BuildContext context) {
    return header(classes: _header.name, [
      nav(
        classes: (container + _nav).name,
        attributes: const {'aria-label': 'Primary'},
        [
          a(
            href: '/',
            classes: _brand.name,
            attributes: const {'aria-label': '$siteName home'},
            const [Logo()],
          ),
          ul(classes: _links.name, [
            const li([
              a(href: docsPath, [.text('Docs')]),
            ]),
            // Secondary: dropped on narrow screens, where the row would not fit.
            li(classes: _secondary.name, const [
              a(href: '$docsPath/example-app', [.text('Examples')]),
            ]),
            li([
              externalLink(pubUrl, label: '$siteName on pub.dev', [
                Icon.package.build(size: 18),
              ]),
            ]),
            li([
              externalLink(repoUrl, label: '$siteName on GitHub', [
                Icon.github.build(size: 18),
              ]),
            ]),
            li([
              button(
                classes: _toggle.name,
                attributes: const {
                  'type': 'button',
                  'data-theme-toggle': '',
                  'aria-label': 'Toggle theme',
                  'title': 'Toggle theme',
                },
                [
                  span(classes: _sun.name, [Icon.sun.build(size: 18)]),
                  span(classes: _moon.name, [Icon.moon.build(size: 18)]),
                ],
              ),
            ]),
          ]),
        ],
      ),
    ]);
  }
}
