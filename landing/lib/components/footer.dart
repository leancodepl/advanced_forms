import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/nav_bar.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The closing call to action, the link columns and the colophon.
class SiteFooter extends StatelessComponent {
  const SiteFooter({required this.version, super.key});

  final String version;

  @css
  static List<StyleRule> get styles => [
    css('.af-footer').styles(
      border: .only(top: hairlineSide(borderColor)),
      fontSize: 1.rem,
      backgroundColor: bg2Color,
    ),
    css('.af-cta').styles(
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
    css('.af-cta-inner').styles(maxWidth: 40.rem, textAlign: .center),
    css(
      '.af-cta h2',
    ).styles(fontSize: const .expression('clamp(1.9rem, 3.6vw, 2.75rem)')),
    css('.af-cta p').styles(
      margin: .only(top: 1.rem),
      color: text2Color,
      fontSize: 1.1.rem,
    ),
    css('.af-footer-grid').styles(
      display: .grid,
      padding: .symmetric(vertical: 3.5.rem, horizontal: .zero),
      gap: .all(2.5.rem),
    ),
    css('.af-footer-grid h3').styles(
      margin: .only(bottom: 0.9.rem),
      color: mutedColor,
      fontFamily: fontMono,
      fontSize: 0.72.rem,
      fontWeight: .w600,
      textTransform: .upperCase,
      letterSpacing: 0.08.em,
    ),
    css('.af-footer-grid ul').styles(display: .grid, gap: .all(0.5.rem)),
    css('.af-footer-grid li a').styles(color: text2Color),
    css('.af-footer-grid li a:hover').styles(color: accentTextColor),
    css('.af-footer-brand .af-logo img').styles(height: 44.px),
    css('.af-footer-brand p').styles(
      maxWidth: 24.rem,
      margin: .only(top: 1.rem),
      color: text2Color,
      fontSize: 0.95.rem,
    ),
    // Links in running text are underlined, not only coloured.
    css('.af-footer-brand p a').styles(color: textColor, raw: underlinedLink),
    css('.af-footer-bottom').styles(
      display: .flex,
      padding: .only(top: 1.5.rem, bottom: 2.rem),
      border: .only(top: hairlineSide(borderColor)),
      flexWrap: .wrap,
      justifyContent: .spaceBetween,
      gap: .all(0.75.rem),
      color: mutedColor,
      fontSize: 0.85.rem,
    ),
    css('.af-footer-bottom a').styles(color: text2Color, raw: underlinedLink),
    css.media(MediaQuery.all(minWidth: 760.px), [
      css('.af-footer-grid').styles(raw: {'grid-template-columns': '1fr 1fr'}),
    ]),
    css.media(MediaQuery.all(minWidth: 1000.px), [
      css(
        '.af-footer-grid',
      ).styles(raw: {'grid-template-columns': '1.6fr 1fr 1fr 1.4fr'}),
    ]),
  ];

  @override
  Component build(BuildContext context) {
    return footer(classes: 'af-footer', [
      const section(
        classes: 'af-cta',
        attributes: {'aria-labelledby': 'cta-heading'},
        [
          div(classes: 'af-container af-cta-inner', [
            h2(id: 'cta-heading', [.text('Ready to type your first field?')]),
            p([
              .text(
                'One dependency, one import, and a form that tells you when it '
                'can be submitted.',
              ),
            ]),
            div(classes: 'af-hero-actions af-center', [
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
      div(classes: 'af-container af-footer-grid', [
        div(classes: 'af-footer-brand', [
          logo(),
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
      div(classes: 'af-container af-footer-bottom', [
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
