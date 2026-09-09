import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The site header: the word mark on the left, the places a visitor can go on
/// the right. The docs are a separate app under `/docs`, served from the same
/// domain, so every item is a plain link.
class NavBar extends StatelessComponent {
  const NavBar({super.key});

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
/// its `public/` folder, so the two sites share one pair of assets. The
/// intrinsic size is the SVG's viewBox; the stylesheet sets the height and the
/// browser keeps the ratio, so the space is reserved before the file arrives.
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
