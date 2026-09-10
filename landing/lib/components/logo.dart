import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The designed word mark: `logo-light.svg` on the light theme and
/// `logo-dark.svg` on the dark one. Both files are served by the docs app from
/// its `public/` folder, so the two sites share one pair of assets, and the
/// class names here are the ones the docs' `global.css` uses for the same
/// mark.
class Logo extends StatelessComponent {
  const Logo({this.large = false, super.key});

  /// The footer size. The regular mark fits a header row, and shrinks a
  /// little more on narrow screens so that row still fits.
  final bool large;

  static const _logo = ClassName('af-logo');
  static const _large = ClassName('af-logo-large');
  static const _light = ClassName('af-logo-light');
  static const _dark = ClassName('af-logo-dark');

  @css
  static List<StyleRule> get styles => [
    css(_logo.selector).styles(display: .inlineFlex, alignItems: .center),
    // The intrinsic size is the SVG's viewBox; the height is set here and the
    // browser keeps the ratio, so the space is reserved before the file
    // arrives.
    css(
      '${_logo.selector} img',
    ).styles(width: .auto, height: 34.px, raw: {'vertical-align': 'middle'}),
    css('${_large.selector} img').styles(height: 44.px),
    // One file per theme.
    css(_dark.selector).styles(display: .none),
    css('.dark ${_light.selector}').styles(display: .none),
    css('.dark ${_dark.selector}').styles(display: .inline),
    css.media(MediaQuery.all(maxWidth: 540.px), [
      css(
        '${_logo.selector}:not(${_large.selector}) img',
      ).styles(height: 28.px),
    ]),
  ];

  @override
  Component build(BuildContext context) {
    return span(classes: (large ? _logo + _large : _logo).name, [
      img(
        src: '/logo-light.svg',
        alt: siteName,
        width: 1480,
        height: 388,
        classes: _light.name,
      ),
      img(
        src: '/logo-dark.svg',
        alt: siteName,
        width: 1480,
        height: 388,
        classes: _dark.name,
      ),
    ]);
  }
}
