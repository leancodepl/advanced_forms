import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/example_frame.dart';
import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/pill.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Hero extends StatelessComponent {
  const Hero({required this.version, required this.demo, super.key});

  final String version;
  final LandingExample demo;

  @override
  Component build(BuildContext context) {
    return section(
      id: 'top',
      classes: 'af-hero',
      attributes: const {'aria-labelledby': 'hero-heading'},
      [
        const div(
          classes: 'af-hero-bg',
          attributes: {'aria-hidden': 'true'},
          [],
        ),
        div(classes: 'af-container af-hero-grid', [
          div([
            p(classes: 'af-hero-badges', [
              Pill('v$version', href: pubUrl, accent: true),
              const Pill('Apache-2.0'),
              const Pill('Easy to use'),
              const Pill('Time-saving'),
              const Pill('Out of the box'),
            ]),
            const h1(id: 'hero-heading', [
              .text('Complicated forms. '),
              span(classes: 'af-accent', [.text('Simple code.')]),
            ]),
            const p(classes: 'af-hero-lead', [
              .text(
                'Typed fields, three validation modes out of the box, async '
                'checks with cancellation, cross-field rules and wizards for '
                'Flutter — wired the same way a two-field sign-up is, on the ',
              ),
              code([.text('ChangeNotifier')]),
              .text(' and '),
              code([.text('ValueListenable')]),
              .text(' your app already uses.'),
            ]),
            div(classes: 'af-install', [
              div(classes: 'af-install-command', [
                const span(
                  classes: 'af-prompt',
                  attributes: {'aria-hidden': 'true'},
                  [.text(r'$')],
                ),
                const code([.text(installCommand)]),
                button(
                  classes: 'af-copy-button',
                  attributes: const {
                    'type': 'button',
                    'data-copy-text': installCommand,
                    'aria-label': 'Copy to clipboard',
                    'aria-live': 'polite',
                  },
                  [
                    span(classes: 'af-copy-idle', [Icon.copy.build(size: 15)]),
                    span(classes: 'af-copy-done', [Icon.check.build(size: 15)]),
                    const span(classes: 'af-copy-label', [.text('Copy')]),
                  ],
                ),
              ]),
              p(classes: 'af-install-alt', [
                const .text('Coming from '),
                const code([.text('leancode_forms')]),
                const .text(' 0.1.x? '),
                externalLink(migrationUrl, [
                  const .text('Read the migration guide'),
                ]),
                const .text('.'),
              ]),
            ]),
            const div(classes: 'af-hero-actions', [
              Button(
                'Build your first form',
                href: '$docsPath/first-form',
                trailing: .arrowRight,
              ),
              Button(
                'pub.dev',
                href: pubUrl,
                variant: .secondary,
                external: true,
                leading: .package,
              ),
              Button(
                'GitHub',
                href: repoUrl,
                variant: .secondary,
                external: true,
                leading: .github,
              ),
            ]),
          ]),
          div(classes: 'af-hero-demo', [
            const p(classes: 'af-demo-label', [
              span(
                classes: 'af-demo-dot',
                attributes: {'aria-hidden': 'true'},
                [],
              ),
              .text(
                'Try it — a live demo running in Flutter. Nothing you type is '
                'sent anywhere.',
              ),
            ]),
            ExampleFrame(example: demo, layout: ExampleLayout.stage),
          ]),
        ]),
      ],
    );
  }
}
