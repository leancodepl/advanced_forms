import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/nav_bar.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class SiteFooter extends StatelessComponent {
  const SiteFooter({required this.version, super.key});

  final String version;

  @override
  Component build(BuildContext context) {
    return footer(classes: 'af-footer', [
      section(
        classes: 'af-cta',
        attributes: const {'aria-labelledby': 'cta-heading'},
        [
          div(classes: 'af-container af-cta-inner', [
            const h2(id: 'cta-heading', [
              .text('Ready to type your first field?'),
            ]),
            const p([
              .text(
                'One dependency, one import, and a form that tells you when it '
                'can be submitted.',
              ),
            ]),
            div(classes: 'af-hero-actions af-center', [
              externalLink(pubUrl, classes: 'af-button af-button-primary', [
                const .text('Get it on pub.dev'),
                Icon.externalLink.build(size: 18),
              ]),
              a(
                href: '$docsPath/first-form',
                classes: 'af-button af-button-secondary',
                [Icon.bookOpen.build(size: 18), const .text('Read the docs')],
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
