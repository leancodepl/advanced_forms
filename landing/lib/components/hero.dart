import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/example_frame.dart';
import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/components/pill.dart';
import 'package:advanced_forms_landing/components/section.dart';
import 'package:advanced_forms_landing/examples.dart';
import 'package:advanced_forms_landing/site.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The hero: badges, the pitch, the install command and the first live demo.
class Hero extends StatelessComponent {
  const Hero({required this.version, required this.demo, super.key});

  final String version;
  final LandingExample demo;

  @css
  static List<StyleRule> get styles => [
    ..._layout,
    ..._copy,
    ..._install,
    ..._demoLabel,
    css.media(MediaQuery.all(minWidth: 1000.px), [
      css('.af-hero-grid').styles(raw: {'grid-template-columns': '1.05fr 1fr'}),
    ]),
    css.media(MediaQuery.all(maxWidth: 540.px), [
      // One row still: the prompt goes, the button shrinks to its icon, and
      // the command scrolls sideways if a screen is narrower than it.
      css('.af-install-command').styles(
        padding: .fromLTRB(0.85.rem, 0.4.rem, 0.4.rem, 0.4.rem),
        gap: .all(0.5.rem),
      ),
      css('.af-install-command code').styles(fontSize: 0.875.rem),
      css('.af-install-command .af-prompt').styles(display: .none),
      css('.af-install-command .af-copy-label').styles(display: .none),
      css('.af-install-command .af-copy-button').styles(padding: .all(0.5.rem)),
    ]),
  ];

  static List<StyleRule> get _layout => [
    css('.af-hero').styles(
      position: const .relative(),
      padding: const .fromLTRB(
        .zero,
        .expression('clamp(3rem, 8vw, 6rem)'),
        .zero,
        .expression('clamp(3rem, 6vw, 4.5rem)'),
      ),
      overflow: .hidden,
      raw: {'isolation': 'isolate'},
    ),
    css('.af-hero-bg').styles(
      position: const .absolute(),
      zIndex: const ZIndex(-1),
      raw: {
        'inset': '0',
        'background': _glow(
          colorMix(accentColor, 55),
          colorMix(accentColor, 25),
          colorMix(textColor, 6),
        ),
        'mask-image': 'linear-gradient(to bottom, #000 30%, transparent 100%)',
        '-webkit-mask-image':
            'linear-gradient(to bottom, #000 30%, transparent 100%)',
      },
    ),
    css('.dark .af-hero-bg').styles(
      raw: {
        'background': _glow(
          colorMix(accentColor, 16),
          colorMix(accentColor, 7),
          colorMix(accentColor, 9),
        ),
      },
    ),
    css(
      '.af-hero-grid',
    ).styles(display: .grid, alignItems: .center, gap: .all(3.rem)),
    css('.af-hero-badges').styles(
      display: .flex,
      margin: .only(bottom: 1.5.rem),
      flexWrap: .wrap,
      gap: .all(0.5.rem),
    ),
    css('.af-hero-actions').styles(
      display: .flex,
      margin: .only(top: 1.75.rem),
      flexWrap: .wrap,
      gap: .all(0.75.rem),
    ),
    css('.af-hero-actions.af-center').styles(justifyContent: .center),
  ];

  /// The backdrop: two accent glows and a fine diagonal hatch, in the colours
  /// each theme needs.
  static String _glow(String glow1, String glow2, String hatch) =>
      'radial-gradient(55% 45% at 72% 18%, $glow1, transparent 65%), '
      'radial-gradient(40% 40% at 10% 90%, $glow2, transparent 60%), '
      'repeating-linear-gradient(-58deg, transparent 0 148px, '
      '$hatch 148px 149px)';

  static List<StyleRule> get _copy => [
    css('.af-hero h1').styles(
      fontSize: const .expression('clamp(2.4rem, 5.2vw, 4rem)'),
      fontWeight: .w700,
      letterSpacing: (-0.035).em,
      lineHeight: const .expression('1.02'),
    ),
    // On light the accent is a highlighter stroke under dark text.
    css(':root:not(.dark) .af-hero h1 .af-accent').styles(
      padding: .symmetric(vertical: .zero, horizontal: 0.1.em),
      margin: .symmetric(vertical: .zero, horizontal: (-0.1).em),
      color: textColor,
      raw: {
        'background': 'linear-gradient(transparent 55%, var(--af-accent) 55%)',
      },
    ),
    css('.af-hero-lead').styles(
      maxWidth: 38.rem,
      margin: .only(top: 1.5.rem),
      color: text2Color,
      fontSize: const .expression('clamp(1.1rem, 1.6vw, 1.3rem)'),
    ),
  ];

  static List<StyleRule> get _install => [
    css('.af-install').styles(margin: .only(top: 2.rem)),
    css('.af-install-command').styles(
      display: .flex,
      maxWidth: 34.rem,
      padding: .fromLTRB(1.rem, 0.5.rem, 0.5.rem, 0.5.rem),
      border: hairline(border2Color),
      radius: const .circular(radius),
      alignItems: .center,
      gap: .all(0.75.rem),
      backgroundColor: surfaceColor,
      raw: {'box-shadow': shadow},
    ),
    css('.af-install-command code').styles(
      minWidth: .zero,
      overflow: const .only(x: .auto),
      fontSize: 0.95.rem,
      whiteSpace: .noWrap,
      raw: {'flex': '1'},
    ),
    css('.af-prompt').styles(
      userSelect: .none,
      color: accentTextColor,
      fontFamily: fontMono,
      fontWeight: .w600,
    ),
    css('.af-install-alt').styles(
      margin: .only(top: 0.6.rem),
      color: mutedColor,
      fontSize: 0.85.rem,
    ),
    css('.af-install-alt a').styles(color: text2Color, raw: underlinedLink),
    // The copy button. `landing.js` sets `data-copied` on it for a moment
    // after a click; the same attribute drives `.af-example-copy` in the
    // example frames.
    css('.af-copy-button').styles(
      display: .inlineFlex,
      padding: .symmetric(vertical: 0.45.rem, horizontal: 0.75.rem),
      border: hairline(border2Color),
      radius: .circular(8.px),
      transition: .combine([
        Transition('color', duration: 150.ms, curve: .ease),
        Transition('border-color', duration: 150.ms, curve: .ease),
      ]),
      alignItems: .center,
      gap: .all(0.4.rem),
      color: text2Color,
      backgroundColor: surfaceColor,
      raw: {'font': '600 0.78rem/1 var(--font-sans)'},
    ),
    css(
      '.af-copy-button:hover',
    ).styles(color: textColor, raw: {'border-color': accentColor.value}),
    css('.af-copy-done').styles(display: .none, color: okColor),
    css('[data-copied="true"]').styles(
      raw: {
        'border-color': '${okColor.value} !important',
        'color': '${okColor.value} !important',
      },
    ),
    css('[data-copied="true"] .af-copy-idle').styles(display: .none),
    css('[data-copied="true"] .af-copy-done').styles(display: .inlineFlex),
  ];

  static List<StyleRule> get _demoLabel => [
    css('.af-demo-label').styles(
      display: .flex,
      margin: .only(bottom: 0.75.rem),
      alignItems: .center,
      gap: .all(0.6.rem),
      color: accentTextColor,
      fontFamily: fontMono,
      fontSize: 0.78.rem,
      fontWeight: .w600,
      textTransform: .upperCase,
      letterSpacing: 0.06.em,
    ),
    css('.af-demo-dot').styles(
      width: 8.px,
      height: 8.px,
      radius: .circular(50.percent),
      flex: .none,
      backgroundColor: okColor,
      raw: {
        'box-shadow': '0 0 0 3px ${colorMix(okColor, 25)}',
        // `Animation` cannot say `infinite`.
        'animation': 'af-pulse 1.6s ease-in-out infinite',
      },
    ),
  ];

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
