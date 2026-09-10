import 'package:advanced_forms_landing/components/button.dart';
import 'package:advanced_forms_landing/components/copy_button.dart';
import 'package:advanced_forms_landing/components/example_frame.dart';
import 'package:advanced_forms_landing/components/pill.dart';
import 'package:advanced_forms_landing/components/text.dart';
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

  static const _class = ClassScope<Hero>();
  static final _hero = _class('af-hero');
  static final _bg = _class('af-hero-bg');
  static final _grid = _class('af-hero-grid');
  static final _badges = _class('af-hero-badges');
  static final _accent = _class('af-accent');
  static final _lead = _class('af-hero-lead');
  static final _install = _class('af-install');
  static final _command = _class('af-install-command');
  static final _prompt = _class('af-prompt');
  static final _installAlt = _class('af-install-alt');
  static final _demo = _class('af-hero-demo');
  static final _demoLabel = _class('af-demo-label');
  static final _demoDot = _class('af-demo-dot');

  @css
  static List<StyleRule> get styles => [
    ..._layout,
    ..._copy,
    ..._installRules,
    ..._demoRules,
    css.media(MediaQuery.all(minWidth: 1000.px), [
      css(_grid.selector).styles(raw: {'grid-template-columns': '1.05fr 1fr'}),
    ]),
    css.media(MediaQuery.all(maxWidth: 540.px), [
      // One row still: the prompt goes, the button shrinks to its icon, and
      // the command scrolls sideways if a screen is narrower than it.
      css(_command.selector).styles(
        padding: .fromLTRB(0.85.rem, 0.4.rem, 0.4.rem, 0.4.rem),
        gap: .all(0.5.rem),
      ),
      css('${_command.selector} code').styles(fontSize: 0.875.rem),
      css('${_command.selector} ${_prompt.selector}').styles(display: .none),
      css(
        '${_command.selector} ${CopyButton.labelClassName.selector}',
      ).styles(display: .none),
      css(
        '${_command.selector} ${CopyButton.className.selector}',
      ).styles(padding: .all(0.5.rem)),
    ]),
  ];

  static List<StyleRule> get _layout => [
    css(_hero.selector).styles(
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
    css(_bg.selector).styles(
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
    css('.dark ${_bg.selector}').styles(
      raw: {
        'background': _glow(
          colorMix(accentColor, 16),
          colorMix(accentColor, 7),
          colorMix(accentColor, 9),
        ),
      },
    ),
    css(
      _grid.selector,
    ).styles(display: .grid, alignItems: .center, gap: .all(3.rem)),
    // Either column may hold a wide code sample; let it shrink and scroll
    // instead of stretching the page.
    css('${_grid.selector} > *').styles(minWidth: .zero),
    css(_badges.selector).styles(
      display: .flex,
      margin: .only(bottom: 1.5.rem),
      flexWrap: .wrap,
      gap: .all(0.5.rem),
    ),
  ];

  /// The backdrop: two accent glows and a fine diagonal hatch, in the colours
  /// each theme needs.
  static String _glow(String glow1, String glow2, String hatch) =>
      'radial-gradient(55% 45% at 72% 18%, $glow1, transparent 65%), '
      'radial-gradient(40% 40% at 10% 90%, $glow2, transparent 60%), '
      'repeating-linear-gradient(-58deg, transparent 0 148px, '
      '$hatch 148px 149px)';

  static List<StyleRule> get _copy => [
    css('${_hero.selector} h1').styles(
      fontSize: const .expression('clamp(2.4rem, 5.2vw, 4rem)'),
      fontWeight: .w700,
      letterSpacing: (-0.035).em,
      lineHeight: const .expression('1.02'),
    ),
    // The accented words of the headline: accent text on dark, a highlighter
    // stroke under dark text on light.
    css(_accent.selector).styles(color: accentTextColor),
    css(':root:not(.dark) ${_hero.selector} h1 ${_accent.selector}').styles(
      padding: .symmetric(vertical: .zero, horizontal: 0.1.em),
      margin: .symmetric(vertical: .zero, horizontal: (-0.1).em),
      color: textColor,
      raw: {
        'background': 'linear-gradient(transparent 55%, var(--af-accent) 55%)',
      },
    ),
    css(_lead.selector).styles(
      maxWidth: 38.rem,
      margin: .only(top: 1.5.rem),
      color: text2Color,
      fontSize: const .expression('clamp(1.1rem, 1.6vw, 1.3rem)'),
    ),
  ];

  static List<StyleRule> get _installRules => [
    css(_install.selector).styles(margin: .only(top: 2.rem)),
    css(_command.selector).styles(
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
    css('${_command.selector} code').styles(
      minWidth: .zero,
      overflow: const .only(x: .auto),
      fontSize: 0.95.rem,
      whiteSpace: .noWrap,
      raw: {'flex': '1'},
    ),
    css(_prompt.selector).styles(
      userSelect: .none,
      color: accentTextColor,
      fontFamily: fontMono,
      fontWeight: .w600,
    ),
    css(_installAlt.selector).styles(
      margin: .only(top: 0.6.rem),
      color: mutedColor,
      fontSize: 0.85.rem,
    ),
    css(
      '${_installAlt.selector} a',
    ).styles(color: text2Color, raw: underlinedLink),
  ];

  static List<StyleRule> get _demoRules => [
    css(_demoLabel.selector).styles(
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
    css(_demoDot.selector).styles(
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
      classes: _hero.name,
      attributes: const {'aria-labelledby': 'hero-heading'},
      [
        div(
          classes: _bg.name,
          attributes: const {'aria-hidden': 'true'},
          const [],
        ),
        div(classes: (container + _grid).name, [
          div([
            p(classes: _badges.name, [
              Pill('v$version', href: pubUrl, accent: true),
              const Pill('Apache-2.0'),
              const Pill('Easy to use'),
              const Pill('Time-saving'),
              const Pill('Out of the box'),
            ]),
            h1(id: 'hero-heading', [
              const .text('Complicated forms. '),
              span(classes: _accent.name, const [.text('Simple code.')]),
            ]),
            p(classes: _lead.name, const [
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
            div(classes: _install.name, [
              div(classes: _command.name, [
                span(
                  classes: _prompt.name,
                  attributes: const {'aria-hidden': 'true'},
                  const [.text(r'$')],
                ),
                const code([.text(installCommand)]),
                const CopyButton(
                  text: installCommand,
                  label: 'Copy',
                  ariaLabel: 'Copy to clipboard',
                ),
              ]),
              p(classes: _installAlt.name, [
                const .text('Coming from '),
                const code([.text('leancode_forms')]),
                const .text(' 0.1.x? '),
                externalLink(migrationUrl, [
                  const .text('Read the migration guide'),
                ]),
                const .text('.'),
              ]),
            ]),
            const ButtonRow([
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
          div(classes: _demo.name, [
            p(classes: _demoLabel.name, [
              span(
                classes: _demoDot.name,
                attributes: const {'aria-hidden': 'true'},
                const [],
              ),
              const .text(
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
