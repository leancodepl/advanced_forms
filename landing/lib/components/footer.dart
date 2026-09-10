import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/logo.dart';
import 'package:advanced_forms_landing/components/text.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The closing call to action, the link columns and the colophon.
class SiteFooter extends StatelessComponent {
  const SiteFooter({required this.version, super.key});

  final String version;

  static const _footer = ClassName('af-footer', owner: SiteFooter);
  static const _cta = ClassName('af-cta', owner: SiteFooter);
  static const _ctaInner = ClassName('af-cta-inner', owner: SiteFooter);
  static const _grid = ClassName('af-footer-grid', owner: SiteFooter);
  static const _brand = ClassName('af-footer-brand', owner: SiteFooter);
  static const _bottom = ClassName('af-footer-bottom', owner: SiteFooter);

  @css
  static List<StyleRule> get styles => [
    css(_footer.selector).styles(
      border: .only(top: hairlineSide(borderColor)),
      fontSize: 1.rem,
      backgroundColor: bg2Color,
    ),
    css(_cta.selector).styles(
      padding: const .symmetric(
        vertical: .expression('clamp(3.5rem, 7vw, 5.5rem)'),
        horizontal: .zero,
      ),
      border: .only(bottom: hairlineSide(borderColor)),
      raw: {
        'background':
            'radial-gradient(50% 60% at 50% 100%, var(--af-accent-soft), '
            'transparent 70%), var(--af-bg-2)',
      },
    ),
    css(_ctaInner.selector).styles(maxWidth: 40.rem, textAlign: .center),
    css(
      '${_cta.selector} h2',
    ).styles(fontSize: const .expression('clamp(1.9rem, 3.6vw, 2.75rem)')),
    css('${_cta.selector} p').styles(
      margin: .only(top: 1.rem),
      color: text2Color,
      fontSize: 1.1.rem,
    ),
    css(_grid.selector).styles(
      display: .grid,
      padding: .symmetric(vertical: 3.5.rem, horizontal: .zero),
      gap: .all(2.5.rem),
    ),
    css('${_grid.selector} h3').styles(
      margin: .only(bottom: 0.9.rem),
      color: mutedColor,
      fontFamily: fontMono,
      fontSize: 0.72.rem,
      fontWeight: .w600,
      textTransform: .upperCase,
      letterSpacing: 0.08.em,
    ),
    css('${_grid.selector} ul').styles(display: .grid, gap: .all(0.5.rem)),
    css('${_grid.selector} li a').styles(color: text2Color),
    css('${_grid.selector} li a:hover').styles(color: accentTextColor),
    css('${_brand.selector} p').styles(
      maxWidth: 24.rem,
      margin: .only(top: 1.rem),
      color: text2Color,
      fontSize: 0.95.rem,
    ),
    // Links in running text are underlined, not only coloured.
    css('${_brand.selector} p a').styles(color: textColor, raw: underlinedLink),
    css(_bottom.selector).styles(
      display: .flex,
      padding: .only(top: 1.5.rem, bottom: 2.rem),
      border: .only(top: hairlineSide(borderColor)),
      flexWrap: .wrap,
      justifyContent: .spaceBetween,
      gap: .all(0.75.rem),
      color: mutedColor,
      fontSize: 0.85.rem,
    ),
    css('${_bottom.selector} a').styles(color: text2Color, raw: underlinedLink),
    css.media(MediaQuery.all(minWidth: 760.px), [
      css(_grid.selector).styles(raw: {'grid-template-columns': '1fr 1fr'}),
    ]),
    css.media(MediaQuery.all(minWidth: 1000.px), [
      css(
        _grid.selector,
      ).styles(raw: {'grid-template-columns': '1.6fr 1fr 1fr 1.4fr'}),
    ]),
  ];

  @override
  Component build(BuildContext context) {
    return footer(classes: _footer.name, [
      section(
        classes: _cta.name,
        attributes: const {'aria-labelledby': 'cta-heading'},
        [
          div(classes: (container + _ctaInner).name, const [
            h2(id: 'cta-heading', [.text('Ready to type your first field?')]),
            p([
              .text(
                'One dependency, one import, and a form that tells you when it '
                'can be submitted.',
              ),
            ]),
            ButtonRow(center: true, [
              Button(
                'Get it on pub.dev',
                href: pubUrl,
                external: true,
                trailing: .externalLink,
              ),
              Button(
                'Read the docs',
                href: '$docsPath/first-form',
                variant: .secondary,
                leading: .bookOpen,
              ),
            ]),
          ]),
        ],
      ),
      div(classes: (container + _grid).name, [
        div(classes: _brand.name, [
          const Logo(large: true),
          p([
            const .text('Form validation and state management for Flutter. '),
            externalLink(changelogUrl, [.text('v$version')]),
            const .text(', Apache-2.0.'),
          ]),
        ]),
        nav(
          attributes: const {'aria-label': 'Project'},
          [
            const h3([.text('Project')]),
            ul([
              li([
                externalLink(pubUrl, [const .text('pub.dev')]),
              ]),
              li([
                externalLink(repoUrl, [const .text('GitHub')]),
              ]),
              li([
                externalLink(changelogUrl, [const .text('Changelog')]),
              ]),
              li([
                externalLink(issuesUrl, [const .text('Issues')]),
              ]),
              li([
                externalLink(apiReferenceUrl, [const .text('API reference')]),
              ]),
            ]),
          ],
        ),
        const nav(
          attributes: {'aria-label': 'Docs'},
          [
            h3([.text('Docs')]),
            ul([
              li([
                a(href: '$docsPath/installation', [.text('Installation')]),
              ]),
              li([
                a(href: '$docsPath/first-form', [.text('Your first form')]),
              ]),
              li([
                a(href: '$docsPath/validation/modes', [
                  .text('Validation modes'),
                ]),
              ]),
              li([
                a(href: '$docsPath/validation/async', [
                  .text('Async validation'),
                ]),
              ]),
              li([
                a(href: '$docsPath/faq', [.text('FAQ')]),
              ]),
            ]),
          ],
        ),
        nav(
          attributes: const {'aria-label': 'LeanCode'},
          [
            const h3([.text('LeanCode')]),
            ul([
              li([
                externalLink(leancodeUrl, [const .text('leancode.co')]),
              ]),
              li([
                externalLink(patrolUrl, [const .text('Patrol')]),
              ]),
              li([
                externalLink(leancodePackagesUrl, [
                  const .text('More packages'),
                ]),
              ]),
              li([
                externalLink(leancodeEstimateUrl, [
                  const .text('Hire our team'),
                ]),
              ]),
            ]),
          ],
        ),
      ]),
      div(classes: (container + _bottom).name, [
        p([
          .text('© ${DateTime.now().year} '),
          externalLink(leancodeUrl, [const .text('LeanCode')]),
          const .text('. Apache License 2.0.'),
        ]),
        p([
          const .text('Built with '),
          externalLink('https://jaspr.site', [const .text('Jaspr')]),
          const .text(
            '. The examples on this site run in Flutter, in your browser.',
          ),
        ]),
      ]),
    ]);
  }
}
