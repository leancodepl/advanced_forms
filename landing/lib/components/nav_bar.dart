import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The site header: the word mark on the left, the places a visitor can go on
/// the right. The docs are a separate app under `/docs`, served from the same
/// domain, so every item is a plain link.
class NavBar extends StatelessComponent {
  const NavBar({super.key});

  @css
  static List<StyleRule> get styles => [
    css('.af-header').styles(
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
    css('.af-nav').styles(
      display: .flex,
      height: 100.percent,
      justifyContent: .spaceBetween,
      alignItems: .center,
      gap: .all(1.rem),
    ),
    css('.af-brand').styles(display: .inlineFlex, alignItems: .center),
    css('.af-logo').styles(display: .inlineFlex, alignItems: .center),
    // The intrinsic size is the SVG's viewBox; the height is set here and the
    // browser keeps the ratio, so the space is reserved before the file
    // arrives.
    css(
      '.af-logo img',
    ).styles(width: .auto, height: 34.px, raw: {'vertical-align': 'middle'}),
    // One file per theme.
    css('.af-theme-dark').styles(display: .none),
    css('.dark .af-theme-light').styles(display: .none),
    css('.dark .af-theme-dark').styles(display: .inline),
    css(
      '.af-nav-links',
    ).styles(display: .flex, alignItems: .center, gap: .all(0.25.rem)),
    css('.af-nav-links a, .af-theme-toggle').styles(
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
      '.af-nav-links a:hover, .af-theme-toggle:hover',
    ).styles(color: textColor, backgroundColor: surface2Color),
    css('.af-theme-toggle').styles(padding: .all(0.5.rem)),
    css('.af-theme-moon').styles(display: .none),
    css('.dark .af-theme-sun').styles(display: .none),
    css('.dark .af-theme-moon').styles(display: .inlineFlex),
    css.media(MediaQuery.all(maxWidth: 540.px), [
      css('.af-nav-links a, .af-theme-toggle').styles(
        padding: .symmetric(vertical: 0.5.rem, horizontal: 0.55.rem),
        fontSize: 0.9.rem,
      ),
      css('.af-nav-links').styles(gap: const .all(.zero)),
      // Examples is reachable from the docs; the row has to fit next to the
      // logo.
      css('.af-nav-secondary').styles(display: .none),
      css('.af-logo img').styles(height: 28.px),
    ]),
  ];

  @override
  Component build(BuildContext context) {
    return header(classes: 'af-header', [
      nav(
        classes: 'af-container af-nav',
        attributes: const {'aria-label': 'Primary'},
        [
          a(
            href: '/',
            classes: 'af-brand',
            attributes: const {'aria-label': '$siteName home'},
            [logo()],
          ),
          ul(classes: 'af-nav-links', [
            const li([
              a(href: docsPath, [.text('Docs')]),
            ]),
            // Secondary: dropped on narrow screens, where the row would not fit.
            const li(classes: 'af-nav-secondary', [
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
                classes: 'af-theme-toggle',
                attributes: const {
                  'type': 'button',
                  'data-theme-toggle': '',
                  'aria-label': 'Toggle theme',
                  'title': 'Toggle theme',
                },
                [
                  span(classes: 'af-theme-sun', [Icon.sun.build(size: 18)]),
                  span(classes: 'af-theme-moon', [Icon.moon.build(size: 18)]),
                ],
              ),
            ]),
          ]),
        ],
      ),
    ]);
  }
}

/// The designed word mark: `logo-light.svg` on the light theme and
/// `logo-dark.svg` on the dark one. Both files are served by the docs app from
/// its `public/` folder, so the two sites share one pair of assets. Sized and
/// switched by `.af-logo` and `.af-theme-*` in [NavBar.styles].
Component logo() => const span(classes: 'af-logo', [
  img(
    src: '/logo-light.svg',
    alt: siteName,
    width: 1480,
    height: 388,
    classes: 'af-theme-light',
  ),
  img(
    src: '/logo-dark.svg',
    alt: siteName,
    width: 1480,
    height: 388,
    classes: 'af-theme-dark',
  ),
]);
